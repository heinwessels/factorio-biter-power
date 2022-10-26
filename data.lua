require("prototypes.generator")
require("prototypes.biters"){
  -- fuel_value="300MJ" -- Can run for 5 minutes
  fuel_value="15MJ" -- Only for testing.
}
require("prototypes.incubator"){
  breeding_success_rate=0.9, 
  -- breeding_time=60,
  breeding_time=1, -- Only for testing
}
require("prototypes.revitalization-center"){
  revitalization_rate=0.9, 
  -- revitalization_time=60, 
  revitalization_time=1,  -- Only for testing
  egg_drop_rate=0.1
}
require("prototypes.buried-biter-nest")
require("prototypes.biter-relocation-center")