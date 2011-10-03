ActiveAdmin.register Venue do

  form do |f|
    f.inputs "Details" do
      f.input :name
      f.input :city, :as => :select, :collection => City.all
      f.input :address
      f.input :type, :as => :select, :collection => [ 'bar', 'club' ]
      f.input :price, :as => :select, :collection => { '$' => 1, '$$' => 2, '$$$' => 3, '$$$$' => 4, '$$$$$' => 5 }
      f.input :hours
      f.input :phone
    end
    f.buttons
  end

  index do
    column :name
    column :city
    column :address
    column :type
    column :price
    column :hours
    column :phone
    column :created_at
    column "" do |venue|
      link_to "Edit", edit_git_er_done_venue_path(venue)
    end
  end

  show do
    h3 venue.name
    div do
      simple_format venue.address
    end
  end

  controller do
    def show
      @venue = Venue.find_by_encoded_id(params[:id])
    end
    def edit
      @venue = Venue.find_by_encoded_id(params[:id])
    end
    def update
      @venue = Venue.find_by_encoded_id(params[:id])

      @venue.update_attributes(params[:venue])
      @venue.save!

      redirect_to git_er_done_venue_path @venue
    end
  end

end
