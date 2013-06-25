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
    "region",
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
      allowed_params = clean_params(params)
      query = join_queries(
        generate_custom_queries(allowed_params) +
        generate_normal_queries(allowed_params)
      )
      where(query.to_s)
    end


    private
    def join_queries(queries)
      queries.join(" AND ")
    end

    def generate_normal_queries(params)
      queries = Array.new
      queries.push(params.map{|k,v| "#{k}=#{ActiveRecord::Base.sanitize(v)}"}) unless params.empty?
      queries
    end
    #
    # General query method to expose private methods
    def generate_custom_queries(params)
      queries = Array.new
      METHOD_PARAMS.each do |param|
        value = params.delete(param)
        queries.push(send("#{param}_query".to_sym, value)) unless value.nil?
      end
      queries
    end
    #
    #.clean_params
    #
    # Cleans the parameters passed in by the user
    #
    # @params parameter the user wantst to query the database for
    def clean_params(params) 
      params.select{ |k,v| ALLOWED_PARAMS.include?(k.downcase) }
    end

    # .on
    #
    # Generate a sql query string for the on parameter
    #
    # @params query the time in unix format to reference the day from
    def on_query(query)
      "occured_at > #{Time.at(query.to_i).beginning_of_day.to_i} AND occured_at < #{Time.at(query.to_i).end_of_day.to_i}"
    end

    # .since
    #
    # Generate a sql query string for the since parameter
    #
    # @params query the time in unix format
    def since_query(query)
      "occured_at > #{query}"
    end

    # .over
    #
    # Generate a sql query string for the magnitude parameter
    #
    # @params query the magnitude to filter by
    def over_query(query)
      "magnitude > #{query}"
    end

    # .near
    #
    # Generate a sql query string for the near parameter
    #
    # @params query the coordinates [lat,lng] to filter by
    def near_query(query)
      lat, lng = query.split(",")
      "latitude >= #{lat.to_f - 5} AND latitude <= #{lat.to_f + 5} AND longitude >= #{lng.to_f - 5} AND longitude <= #{lng.to_f + 5}"
    end
  end
end
