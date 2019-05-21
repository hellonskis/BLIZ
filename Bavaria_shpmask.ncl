load "/usr/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/usr/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/usr/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/usr/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "/usr/lib/ncarg/nclscripts/shapefile_utils.ncl"

;*******************************************
begin
;*******************************************  

shpname = "./Bayern/bayern_ex.shp"
maskname = "./Bayern_mask.nc"

print_shapefile_info(shpname)

;-- open data file to get the grid to be used
f = addfile("pr_Bayern_hydbav-EUR-11_ICHEC-EC-EARTH_rcp85_r1i1p1_KNMI-RACMO22E_DT-TRANS-KliRef2014_monsum_19710101-21001231.nc","r")     ; monthly precip
;f = addfile("pr_Bayern_hydbav-EUR-11_ICHEC-EC-EARTH_rcp45_r1i1p1_KNMI-RACMO22E_DT-TRANS-KliRef2014_monsum_19710101-21001231.nc","r")     ; monthly precip  

;-- read variable
pr         = f->pr(0,:,:)
pr@lat2d   = f->lat
pr@lon2d   = f->lon

;-- shapefile mask resources
opt             =  True
opt@return_mask =  True    ;-- this forces the return of a 0s and 1s mask array

;-- create the mask from the shapefile
mask_array             =  shapefile_mask_data(pr, shpname, opt)
mask_array!0           = "y" 
mask_array!1           = "x" 
mask_array@coordinates = "lat lon"

;-- create new netCDF file and write mask array
system("rm -f " + maskname)
fout = addfile(maskname,"c")

fout->mask_array =  mask_array
fout->lat        =  f->lat
fout->lon        =  f->lon

end
