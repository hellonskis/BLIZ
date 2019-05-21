load "/usr/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/usr/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/usr/lib/ncarg/nclscripts/csm/contributed.ncl"

;*******************************************
begin
;*******************************************  

;-- Input file; select .125- or .25-degree coordinates .txt file
;f = "Bavaria_25_coords.txt"
f = "Bavaria_125_coords.txt"

;-- Output file; .125- or .25-degree. Should be the same resolution as the input file. 
;mask_outname = "Bavaria_WGS_25_mask.nc"
mask_outname = "Bavaria_WGS_125_mask.nc"
 
;-- Get time coordinate from somewhere to use as record variable
g = addfile("pr_Bayern_hydbav-EUR-11_ICHEC-EC-EARTH_rcp85_r1i1p1_KNMI-RACMO22E_DT-TRANS-KliRef2014_monsum_19710101-21001231.nc","r")     ; monthly precip
time = g->time
ntime  = dimsizes(time)

ncol = numAsciiCol(f)
nrow = numAsciiRow(f)

data_mask = readAsciiTable(f,ncol,"float",1)
print(dimsizes(data_mask))

lon_array = get_unique_values(data_mask(:,0))
lat_array = get_unique_values(data_mask(:,1))

min_lat = min(lat_array)
max_lat = max(lat_array)
min_lon = min(lon_array)
max_lon = max(lon_array)
  
lon_count = count_unique_values(data_mask(:,0))
lat_count = count_unique_values(data_mask(:,1))

start_year  = 1971            ; first year of monthly .nc file
end_year    = 2100            ; last year of monthly .nc file
month_count = ((end_year - start_year + 1)*12)

nlon = lon_count
nlat = lat_count
nmonth = month_count
 
lat_new = new((/lat_count/),"double",0)
lat_new@units = "degrees_north"
lon_new = new((/lon_count/),"double",0)
lon_new@units = "degrees_east"
time_new = new((/(ntime)/),"double",0)
time_new@units = "days since 1971-01-01" 

do lt=0, nlat-1
  lat_new(lt) = lat_array(lt)
end do
do ln=0, nlon-1
  lon_new(ln) = lon_array(ln)
end do
do tt=0, nmonth-1
  time_new(tt) = time(tt)
end do

;-- Create variable for masking and populate with fill values

msk = new((/nmonth,nlat,nlon/),"double",0)
msk!0="time"
msk!1="lat"
msk!2="lon"
msk&time = time_new
msk&lat = lat_new
msk&lon = lon_new
msk@_FillValue = -9999

;-- Create netcdf mask file

system("rm -rf "+mask_outname)
g = addfile(mask_outname,"c")
g->mask = msk
  
print("Writing mask file...")

Bav_mask = g->mask

print(dimsizes(data_mask))
print(nrow-1)

do tt=0, nmonth-1
  do rr=0, nrow-2
    do ln=0, nlon-1
      if (data_mask(rr,0) .eq. lon_array(ln))
        do lt=0, nlat-1
          if (data_mask(rr,1) .eq. lat_array(lt))
            Bav_mask(tt,lt,ln) = 1.
          end if
        end do
      end if
    end do
  end do
end do

g->mask = Bav_mask

print("done")

end

