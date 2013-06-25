#earthquake factory
FactoryGirl.define do
  factory :earthquake do
    source      "ak"
    eqid        1234
    version     1
    occured_at  1364582194
    latitude    36.6702
    longitude   -114.8870
    magnitude   2.0
    depth       5.5
    nst         19
    region      "Southern California"
  end
end
