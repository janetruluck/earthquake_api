# Earthquake.rb
class Earthquake < ActiveRecord::Base
  # define accessible attributes
  attr_accessible :source, :eqid, :version, :occured_at, :latitude, :longitude, :magnitude, :depth, :nst, :region

  # Validate the earthquake is unique via its earthquake id
  validates :eqid, :uniqueness => true

  # Denote params that require special sql
  METHOD_PARAMS = [
    "since",
    "over",
    "on",
    "near"
  ]
  # Denote allowed parameters to whitelist query attributes
  ALLOWED_PARAMS = [
    "source",
    "eqid",
    "version",
    "occured_at",
    "latitude",
    "longitude",
    "magnitude",
    "depth",
    "nst",
    "region"
  ] + METHOD_PARAMS

  # Class methods
  class << self
    # .import
    #
    # Import data from a remote source, defaults to USGS
    #
    # @params url the url of the data source
    #
    # @author Jason Truluck
    def import(url = "http://earthquake.usgs.gov/earthquakes/catalogs/eqs7day-M1.txt")
      open(url) do |file|
        CSV.foreach(file, {:headers => true}) do |row|
          # Map attributes to earthquake object and save
          Earthquake.create(
            :source     => row[0],
            :eqid       => row [1],
            :version    => row [2],
            :occured_at => Time.parse(row[3]).to_i, # Parse into time object then convert to Unix time
            :latitude   => row[4],
            :longitude  => row[5],
            :magnitude  => row[6],
            :depth      => row[7],
            :nst        => row[8],
            :region     => row[9]
          )
        end
      end
      # Check if there are imports in the queue or being worked on
      # If there is, do not queue another import for later, its redundant
      unless Resque.size("import") >= 1 || Resque.working.count >= 1
        Resque.enqueue(ImportJob)
      end
    end

    def filter(params)
      clean_params(params)
      on.since.over.near.normal
    end

    # #normal
    #
    #  Scope for normal query params 
    def normal
      @clean_params.blank? ? scoped : where(@clean_params.map{|k,v| "#{k}=#{ActiveRecord::Base.sanitize(v)}"}.join(" AND "))
    end

    # #on
    #
    # Scope for earthquakes on the day specified
    def on
      query = @clean_params.delete("on")
      if query.nil?
        scoped
      else
        start_time  = Time.at(query.to_i).beginning_of_day.to_i
        end_time    = Time.at(query.to_i).end_of_day.to_i
        where("occured_at > ? AND occured_at < ?", start_time , end_time)
      end
    end

    # .since
    #
    # Scope for earthquakes since the day specified
    def since
      query = @clean_params.delete("since")
      query.nil? ? scoped : where("occured_at > ?", query)
    end

    # .over
    #
    # Scope for earthquakes with a magnitude over the specified magnitude
    def over
      query = @clean_params.delete("over")
      query.nil? ? scoped : where("magnitude > ?", query)
    end

    # .near
    #
    # Scope for earthquakes within 5 miles of the coordinates specified
    def near
      query = @clean_params.delete("near")
      if query.nil?
        scoped
      else
        lat, lng = query.split(",") 
        where("latitude >= #{lat.to_f - 5} AND latitude <= #{lat.to_f + 5} AND longitude >= #{lng.to_f - 5} AND longitude <= #{lng.to_f + 5}")
      end
    end

    private
    #
    #.clean_params
    #
    # Cleans the parameters passed in by the user
    #
    # @params parameter the user wants to query the database for
    def clean_params(params) 
      @clean_params = params.select{ |k,v| ALLOWED_PARAMS.include?(k.downcase) }
    end
  end
end
