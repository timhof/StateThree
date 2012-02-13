class Account < ActiveRecord::Base
	
	require 'bigdecimal'
  	require 'bigdecimal/util'

	include StateliHelper
	
	has_many :transactions, :order => "trans_date desc", :conditions => {:active => true}
	has_many :rules, :order => "rank asc"
	
#	named_scope :active_only, :conditions => { :active => true } 
#	named_scope :user_only, lambda { |user_id| { :conditions => { :user_id => user_id } }}
	
	attr_accessor :filtered_transactions
	
	validates_presence_of :name
	
	def self.user_only(user_id)
		where(:user_id => user_id)
	end

	def deleted_transactions
		return Transaction.deleted_transactions(id)
	end
	
	def filtered_transactions(selector)
	  	@filtered_transactions = transactions.select do |trans| 
			pocket_id = trans.pocket_id
			include = selector.selectedPockets[pocket_id] == '1' && trans.trans_date >= selector.startDate && trans.trans_date < selector.endDate && (trans.completed || selector.show_incomplete)
		end
  	end
  
	def update_account_attributes(params)

		self.previous_balance = self.balance
		
 		unless(params[:name].nil?)
 			self.name = params[:name]
 		end
 		unless(params[:description].nil?)
 			self.description = params[:description]
 		end
 		unless(params[:balance].nil?)
 			self.balance = params[:balance].to_d
 		end
 		
 		return self.save
 	end
 	

	def add_upload_transactions(filename, uploadType=nil)
		transactionUploader = TransactionUploader.new
		transactionUploader.type = uploadType
		new_transactions = transactionUploader.parseTransactions(filename)
   		new_transactions.each do |trans|
   			unless has_transaction(trans)
   				p "Adding: "#{trans.trans_date}, #{trans.name}, #{trans.amount}"
   				trans.user_id = user_id
   				trans.account_id = id
   				trans.completed = true
   				trans.save!
   			end
   		end
   		reload
   	end
   	
	def has_transaction(transaction)
		
		return transactions.to_a.any? do |trans|
			trans.trans_date == transaction.trans_date && trans.name == transaction.name && trans.amount == transaction.amount
		end
	end
		
			
	def reload_transactions
		
		puts "RELOADING TRANSACTIONS"
		self.reload
	end
	
	def completed_transactions_by_date(start_date, end_date)
		return completed_transactions
	end

	def completed_transactions
		
		completed_transactions = []
		transactions.each do |trans|
			if trans.completed
				completed_transactions << trans
			end
		end
		return completed_transactions
	end
	
	def active_transactions
		
		active_transactions = []
		transactions.each do |trans|
			if trans.active
				active_transactions << trans
			end
		end
		return active_transactions
	end
	
	def execute_deposit(params)
  		transaction = Transaction.new(params)
  		transaction.amount = transaction.amount.to_d
  		transaction.trans_date = Date.today
    	
    	self.execute_transaction(transaction)
    	
  		 logger.info "Executing #{transaction.type} transactionddfd"
  		return transaction
  	end
  	
  	def execute_withdrawal(params)
  		transaction = Transaction.new(params)
  		transaction.amount = 0 - transaction.amount.to_d
  		transaction.trans_date = Date.today
    
      	self.execute_transaction(transaction)
      	
  		return transaction
  	end
  	
  	def execute_transaction(transaction)
  		transaction.completed = true
    	transaction.user_id = self.user_id
    	transaction.account = self
    	puts "Saving Transaction"
    	if transaction.save!
      		self.reload_transactions
  		end
 	end
 		
 	def removeAllTransactions()
    	transactions.each do |trans|
    		trans.destroy
  		end
  		self.reload_transactions
 	end
 	
 	def apply_rules
		transactions.each do |trans|
			rules.each do |rule|
				if rule.condition_match?(trans)
					rule.apply_action(trans)
					break
				end
			end
		end
		self.reload
	end
	
	def pocket_map(filtered_transactions)
	
		pocket_map = {}
		filtered_transactions.each do |trans|
			pocket_id = trans.pocket_id
			pocket_map[pocket_id] ||= 0
			pocket_map[pocket_id] = pocket_map[pocket_id] + trans.amount
		end
		return pocket_map
	end
	
	def month_pocket_map(filtered_transactions)
		
		month_pocket_map = {}
		filtered_transactions.each do |trans|
			pocket_id = trans.pocket_id
			if pocket_id.nil?
				p "NIL POCKET"
			end
			date = Date.new(trans.trans_date.year, trans.trans_date.month, 1)
			month_pocket_key = "#{(trans.trans_date.year*100) + trans.trans_date.month}_#{pocket_id}"
			month_total_key = "#{(trans.trans_date.year*100) + trans.trans_date.month}_-2"
			month_pocket_map[month_pocket_key] ||= 0
			month_pocket_map[month_pocket_key] = month_pocket_map[month_pocket_key] + trans.amount
		end
		return month_pocket_map
	end	
	
end
