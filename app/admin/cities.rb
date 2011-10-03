ActiveAdmin.register City do

  form do |f|
    f.inputs "Details" do
      f.input :name
      f.input :state_code
      f.input :coordinates_string, :label => "Latitude,Longitude"
    end
  end

  index do
    column :name
    column :state_code
    column "Lat/Lon" do |city|
      "#{city.coordinates[0]}, #{city.coordinates[1]}"
    end
    column :created_at
    #default_actions
  end

  member_action :create, :method => :post do
    city = City.create(
            params[:city]
    )

    redirect_to git_er_done_cities_path
  end

end
