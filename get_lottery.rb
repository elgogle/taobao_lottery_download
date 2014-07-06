#encoding: utf-8

# require 'win32ole'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
# require 'mysql'

$united_list_all_page_link=[]
$detail_link=[]
$united_order_detail_link=[]
$order_detail_next_page_queue=[]

$home_page_url='http://caipiao.taobao.com/lottery/order/united_list.htm?'

$not_full='1'
$full='2'
$issue=ARGV


def get_html(url)
	i = 0
	begin
		i += 1
		txt = open(url)
		return txt.read
	rescue
		puts i.to_s + ' times try open(' + url + ')'
		puts 'sleep 1 seconds and try again'
		sleep 1
		retry
	end
end

#Get detail_link
def get_detail_link(url)
    content = get_html(url)

    content.scan(%r{http\:\/\/caipiao\.taobao\.com\/lottery\/order\/united_detail\.htm\?united_id\=[a-z|A-Z|0-9]*}).each do |item|
        $detail_link << item
        #puts item
    end
end

def get_united_order_detail_link(url)
    content = get_html(url)
    doc = Nokogiri::HTML(content)
    
    xdoc= Nokogiri::HTML( doc.at(".select-num").inner_html )

    if  xdoc.at(".pseudo-switch")  
        $united_order_detail_link << 'http://caipiao.taobao.com/lottery/order/' + xdoc.at(".pseudo-switch").get_attribute("href")
    end
end

def get_order_detail(url, out_file)
    content = get_html(url)

    doc = Nokogiri::HTML(content)
    doc.css('.td2').each do |link|
        puts link.content.strip
        open(out_file+'_lottery_detail.txt','a') do |f|
            f.puts link.content.strip
        end
    end
end

def get_order_detail_next_page_link(order_detail_page_url)
    content = get_html(order_detail_page_url)
    doc = Nokogiri::HTML( content )
    
    max_page=1
    max_page = content.match(/(max_page\s+=\s*)(\d+)/)[2].to_i
    next_page=order_detail_page_url.match(%r{.*\?})
    
     _tb_token_value=''
    page_value=''
    tb_united_id_value=''
    is_history_value=''
    
    xdoc = Nokogiri::HTML(doc.at('form').inner_html)
    xdoc.xpath('/html/body/input').each do |a|
        case a.get_attribute("name")
        when '_tb_token_'
            _tb_token_value=a.get_attribute("value")
        when 'tb_united_id'
            tb_united_id_value=a.get_attribute("value")
        when 'is_history'
            is_history_value=a.get_attribute("value")
        end
    end
                
    if max_page >=2
        (2..max_page).each do |i|
             $order_detail_next_page_queue << next_page.to_s +  '_tb_token_='  + _tb_token_value + '&page=' + i.to_s + '&tb_united_id=' + tb_united_id_value + '&is_history=' + is_history_value
        end
    end        
end

def get_united_list_link(first_url,issue,full_or_not)
    first_base_url='http://caipiao.taobao.com/lottery/ajax/get_united_list.htm?page='
    middle_base_url="&commission_rate=-1&confidential=1&UnitedFee=0-0&is_not_full=#{full_or_not}&issue="
    last_base_url='&lotteryType=SSQ&sort_obj=process&sort=desc&change_sort=&lowAmount=0&highAmount=0'
    
    content = get_html(first_base_url+'1'+middle_base_url+issue+last_base_url)
    total_page = content.match(%r{totalPage.{2}(\d+)})[1]
    puts total_page
    
    (1..total_page.to_i).each do |i|
        $united_list_all_page_link << first_base_url + i.to_s + middle_base_url +issue+last_base_url
    end
end

def get_issue_value()
	content=get_html($home_page_url)
	puts content
	doc = Nokogiri::HTML(content)
	
	issue_set={}
	
	if doc.css("#J_IssueSelection")
		a= doc.css("#J_IssueSelection").inner_html
		xdoc=Nokogiri::HTML(a)
		
		xdoc.search("option").each do |a|
			issue_set[a.text]=a.get_attribute("value")
		end
	end
	return issue_set
end

def get_result(issue)
	if issue.to_s.match(%r{\d+})
		result_link = 'http://caipiao.taobao.com/lottery/awardresult/lottery_ssq.htm'
		issue_link = ''
		
		content=get_html(result_link)
		doc = Nokogiri::HTML(content)
		
		if doc.css(".J_select_op")
			a= doc.css(".J_select_op").inner_html
			xdoc=Nokogiri::HTML(a)
			
			xdoc.search("option").each do |a|
				if a.text == issue[0].to_s
					issue_link=a.get_attribute("value")
				end
			end			
		end
		
		content=get_html(result_link+issue_link)
		doc = Nokogiri::HTML(content)
		red=[]
		blue=nil
		# puts content
		if doc.css(".kk-a")
			a= doc.css(".kk-a").inner_html
			xdoc=Nokogiri::HTML(a)
			
			xdoc.search("span").each do |a|
				if a.get_attribute("class") == "cb"
					red << a.text.to_i
				end
				
				if a.get_attribute("class") == "cb blue-ball"
					blue= a.text.to_i
				end
			end			
		end
		
		if red.length == 6
			begin
				dbh = Mysql.real_connect('localhost', 'root', '', 'Lottery')
				
				dbh.query("insert into ssq_result values(#{issue[0].to_i},#{red[0]},#{red[1]},#{red[2]},#{red[3]},#{red[4]},#{red[5]},#{blue})")
			ensure
				dbh.close
			end		
		end
	end
end

# get_result($issue)

issue_set = get_issue_value()
puts issue_set.to_s

$issue.each do |issue|
 
	get_united_list_link($home_page_url,issue_set[issue],$full)

	threads = []

	for page in $united_list_all_page_link
		threads << Thread.new(page) { |my_page|
			get_detail_link(my_page)
			# get_detail_link(page)
			while $detail_link.length > 0 do
				link_1 = $detail_link.pop
				get_united_order_detail_link(link_1)
				
				while $united_order_detail_link.length > 0 do
					link_2 = $united_order_detail_link.pop
					get_order_detail(link_2,issue)
					get_order_detail_next_page_link(link_2)
				   
					while $order_detail_next_page_queue.length > 0 do
						link_3 = $order_detail_next_page_queue.pop
						get_order_detail(link_3,issue)
					end
				end
			end        
		}
	end

	threads.each { |aThread|  aThread.join }
end


