require 'rubygems'
require 'yaml'
require 'csv'
require 'bing_translator'

BING_ACCOUNT_KEY = ENV['BING_ACCOUNT_KEY']
BING_CUST_ID = ENV['BING_CUSTOMER_ID']

if BING_ACCOUNT_KEY && BING_CUST_ID
	if ARGV.length < 1
		puts "You must provide the filename"
		exit 0;
	end
	file = ARGV[0]
else
	if ARGV.length < 3
		puts "You must provide the account key, customer id, and filename"
		exit 0;
	end
	BING_ACCOUNT_KEY = ARGV[0]
	BING_CUST_ID = ARGV[1]
	file = ARGV[2]
end

translator = BingTranslator.new(BING_CUST_ID, BING_ACCOUNT_KEY)

if file =~ /.\.yml$/i

	data = YAML.load(File.open(file))

	items = { 'es' => {} }

	data['en'].each do |key,value|
		translated = translator.translate(value, :from => 'en', :to => 'es')
		puts "#{value} -> #{translated}"
		items['es'][key] = translated
	end

	File.open("test.yml", "w") {|f| f.write(items.to_yaml) }

elsif file =~ /.\.csv$/i

	items = []

	CSV.foreach(file, { :headers => true} ) do |row|
		puts row.inspect
		key = row['Keys']
		english = row['en-CA']
		spanish = translator.translate(english, :from => 'en', :to => 'es')
		puts "#{english} -> #{spanish}"
		items << [ key, english, spanish ]
	end

	CSV.open('test.csv', 'w') do |csv|
		csv << [ "Keys", "en-CA", "es-US" ]
		items.each do |row|
			csv << row
		end
	end

else

	puts "please choose a YAML or CSV file"
	
end