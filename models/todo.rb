class Todo < ActiveRecord::Base

  belongs_to :user

  validates :content,   presence: true , length: { minimum: 2 }
  validates :status,    presence: true , inclusion: { in: [0,1] }
  validates :priority,  presence: true , inclusion: { in: [0,1,2] }

  def unfinished?
    status == 1
  end

  def finished?
    status == 0
  end

end
