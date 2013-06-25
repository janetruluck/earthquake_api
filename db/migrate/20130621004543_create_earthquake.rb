class CreateEarthquake < ActiveRecord::Migration
  def up
    create_table :earthquakes do |t|
      t.string   :source
      t.integer  :eqid
      t.integer  :version
      t.integer  :occured_at
      t.float    :latitude,  :limit => 53
      t.float    :longitude, :limit => 53
      t.float    :magnitude, :limit => 53
      t.float    :depth,     :limit => 53
      t.integer  :nst
      t.string   :region
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def down
    drop_table :earthquakes
  end
end
