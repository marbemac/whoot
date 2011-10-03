ActiveAdmin.register Tag do

  scope :uncategorized
  scope :trendable
  scope :stopword

  index do
    column :name
    column :score
    column :is_trendable
    column :is_stopword
    column :created_at
    column "" do |tag|
      response = Array.new
      unless tag.is_trendable
        response << link_to("Make Trendable", tag_make_trendable_path(:id => tag.id), :class => 'ac', "data-m" => 'put')
      end
      unless tag.is_stopword
        response << link_to("Make Stopword", tag_make_stopword_path(:id => tag.id), :class => 'ac', "data-m" => 'put')
      end
      response.join(' ').html_safe
    end
  end

end
