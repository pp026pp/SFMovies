object @movie
attributes :id, :title, :release_year, :fun_fact, :production_company, :distributor, :director, :writer, :actor1, :actor2, :actor3
child(:locations) do |location|
  attributes :name, :id
end
