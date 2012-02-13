class Pocket < ActiveRecord::Base
	has_many :transactions
	
	def self.user_pockets(user_id)
		logger.info "GETTING POCKETS"
		pockets = self.find(:all, :conditions => "user_id = #{user_id} or user_id = 1", :order => "name asc")
	end
	
	def self.find_pocket(id)
		begin
			pocket = find(id)
		rescue
			pocket = unclassified
		end
	end
		
	def self.unclassified
		pocket = find_pocket(-100)
		if pocket.nil?
			pocket = Pocket.new
			pocket.id = -100
			pocket.name = "Unclassified"
			pocket.save
		end
		return pocket
	end
end
