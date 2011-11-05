ActiveAdmin.register Tag do

  scope :uncategorized
  scope :trendable
  scope :stopword

  index do
    column :name
    column :score
    column :is_stopword
    column :created_at
    column "" do |tag|
      response = Array.new

      response.join(' ').html_safe
    end
  end

end
