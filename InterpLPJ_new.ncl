load "/usr/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/usr/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/usr/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/usr/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

;*******************************************
begin
;*******************************************  
  
  ;-- Target lat/lon array

  e = addfile("pr_masked_rcp85.nc","r")     ; needed for lat/lon target array
  lat_e = e->lat
  lon_e = e->lon
  targetgrid_dsizes = dimsizes(lat_e)

  ;-- Input files

  f = addfile("pr_masked_rcp85.nc","r")     ; monthly precip file (created using "cdo div [monthly precip file] Bayern_mask.nc pr_masked.nc" 
  g = addfile("tas_masked_rcp85.nc","r")     ; monthly tas file (created using "cdo div [monthly tas file] Bayern_mask.nc tas_masked.nc"
  h = addfile("rsds_masked_rcp85.nc","r")     ; monthly rsds (created using "cdo div [monthly rsds file] Bayern_mask.nc rsds_masked.nc"
;  f = addfile("pr_masked_rcp45.nc","r")     ; monthly precip file (created using "cdo div [monthly precip file] Bayern_mask.nc pr_masked.nc"
;  g = addfile("tas_masked_rcp45.nc","r")     ; monthly tas file (created using "cdo div [monthly tas file] Bayern_mask.nc tas_masked.nc"
;  h = addfile("rsds_masked_rcp45.nc","r")     ; monthly rsds (created using "cdo div [monthly rsds file] Bayern_mask.nc rsds_masked.nc"

  ;-- Destination grid for interpolation; select .25- or .125-degree mask

  ;i = addfile("Bavaria_WGS_25_mask.nc","r")
  i = addfile("Bavaria_WGS_125_mask.nc","r")

  ;-- Name the 3 output files that will be created by this script;  

  ;-- RCP4.5 files; tagged as "regridded_25.nc" or "regridded_125.nc" depending on which resolution target grid file is to be used.
;  pr_outname = "pr_Bayern_hydbav-EUR-11_ICHEC-EC-EARTH_rcp45_r1i1p1_KNMI-RACMO22E_DT-TRANS-KliRef2014_monsum_19710101-21001231_regridded_25.nc"
;  tas_outname = "tas_Bayern_hydbav-EUR-11_ICHEC-EC-EARTH_rcp45_r1i1p1_KNMI-RACMO22E_DT-TRANS-KliRef2014_mon_19710101-21001231_regridded_25.nc"
;  rsds_outname = "rsds_Bayern_hydbav-EUR-11_ICHEC-EC-EARTH_rcp45_r1i1p1_KNMI-RACMO22E_DT-TRANS-KliRef2014_mon_19710101-21001231_regridded_25.nc"
;  pr_outname = "pr_Bayern_hydbav-EUR-11_ICHEC-EC-EARTH_rcp45_r1i1p1_KNMI-RACMO22E_DT-TRANS-KliRef2014_monsum_19710101-21001231_regridded_125.nc"
;  tas_outname = "tas_Bayern_hydbav-EUR-11_ICHEC-EC-EARTH_rcp45_r1i1p1_KNMI-RACMO22E_DT-TRANS-KliRef2014_mon_19710101-21001231_regridded_125.nc"
;  rsds_outname = "rsds_Bayern_hydbav-EUR-11_ICHEC-EC-EARTH_rcp45_r1i1p1_KNMI-RACMO22E_DT-TRANS-KliRef2014_mon_19710101-21001231_regridded_125.nc" 

  ;-- RCP8.5 files; tagged as "regridded_25.nc" or "regridded_125.nc" depending on which resolution target grid file is to be used.
;  pr_outname = "pr_Bayern_hydbav-EUR-11_ICHEC-EC-EARTH_rcp85_r1i1p1_KNMI-RACMO22E_DT-TRANS-KliRef2014_monsum_19710101-21001231_regridded_25.nc"
;  tas_outname = "tas_Bayern_hydbav-EUR-11_ICHEC-EC-EARTH_rcp85_r1i1p1_KNMI-RACMO22E_DT-TRANS-KliRef2014_mon_19710101-21001231_regridded_25.nc"
;  rsds_outname = "rsds_Bayern_hydbav-EUR-11_ICHEC-EC-EARTH_rcp85_r1i1p1_KNMI-RACMO22E_DT-TRANS-KliRef2014_mon_19710101-21001231_regridded_25.nc"
  pr_outname = "pr_Bayern_hydbav-EUR-11_ICHEC-EC-EARTH_rcp85_r1i1p1_KNMI-RACMO22E_DT-TRANS-KliRef2014_monsum_19710101-21001231_regridded_125.nc"
  tas_outname = "tas_Bayern_hydbav-EUR-11_ICHEC-EC-EARTH_rcp85_r1i1p1_KNMI-RACMO22E_DT-TRANS-KliRef2014_mon_19710101-21001231_regridded_125.nc"
  rsds_outname = "rsds_Bayern_hydbav-EUR-11_ICHEC-EC-EARTH_rcp85_r1i1p1_KNMI-RACMO22E_DT-TRANS-KliRef2014_mon_19710101-21001231_regridded_125.nc"

;****************************************************************************************************
;************************ Write precip file *********************************************************

  pr   = f->pr(:,:,:)
  lati = f->lat
  loni = f->lon
  time = f->time

  invar = pr
  load "get_xy_limits.ncl" 

  nlat   = targetgrid_dsizes(0)
  nlon   = targetgrid_dsizes(1)
  ntime  = dimsizes(time)

  lat_new = new((/nlat/),"double",0)
  lat_new@units = "degrees_north"
  lat_new@standard_name = "latitude"
  lat_new@long_name = "latitude"
  lon_new = new((/nlon/),"double",0)
  lon_new@units = "degrees_east"
  lon_new@standard_name = "longitude"
  lon_new@long_name = "longitude"
  time_new = new((/(ntime)/),"double",0)
  time_new@units = "days since 1971-01-01" 

  do lt=0, nlat-1
     lat_new(lt) = min(lati) + (((max(lati)-min(lati))/(nlat-1))*lt)
  end do

  do ln=0, nlon-1
     lon_new(ln) = min(loni) + (((max(loni)-min(loni))/(nlon-1))*ln)
  end do
 
  do tt=0, ntime-1
     time_new(tt) = time(tt)
  end do

  prNew = new((/ntime,nlat,nlon/),"double",0)
  prNew!0="time"
  prNew!1="lat"
  prNew!2="lon"
  prNew&time = time_new
  prNew&lat = lat_new
  prNew&lon = lon_new
  prNew@standard_name = "precipitation"
  prNew@long_name = "precipitation"
  prNew@units = "mm/month"
  prNew@_FillValue = default_fillvalue("double")  
  prNew@coordinates = "lat lon"

  outname = "pr_out_85.nc"
  system("rm -rf "+outname)
  j = addfile(outname,"c")
  j->pr = prNew

  ;-- Write .nc file with rotated coordinates reprojected to flat map
  print("Writing precip file...")

  pr_new = j->pr(:,:,:)

  do tt=0, ntime-1
    do nln=0, nlon-1
      do ln=x_minlim, x_maxlim
        if (ln .eq. (nln + x_minlim))
          do nlt=0, nlat-1
            do lt=y_minlim, y_maxlim
              if (lt .eq. (nlt + y_minlim))
                pr_new(tt,nlt,nln) = (/pr(tt,lt,ln)/)
              end if
            end do
          end do
        end if
      end do
    end do
  end do
            
  j->pr = pr_new

  print("precip file written")
  print("regridding...")

  ; Create mask for interpolation

  prMask = new((/nlat,nlon/),"double",0)
  prMask!0="lat"
  prMask!1="lon"
  prMask&lat = lat_new
  prMask&lon = lon_new

  j->prMask = prMask
  pmask = j->pr
  pr_msk = j->prMask(:,:)

  do lt=0, nlat-1
    do ln=0, nlon-1
      pr_msk(lt,ln) = where(.not.ismissing(pmask(0,lt,ln)),1,0)
    end do
  end do

  j->prMask = pr_msk
  bavaria_mask_pr = j->prMask

  ;-- Regrid the data from source grid to new destination grid
  ;-- Assign output file name  

  ;-- Create output file and populate with lat/lon dummy array
  pr_mask    = i->mask
  system("rm -rf "+pr_outname)
  k = addfile(pr_outname,"c")
  k->pr = pr_mask  

  ;-- Create 2D mask
  gridmask2D = i->mask(0,:,:)

  SrcGrid    = addfile(outname,"r")
  pr_source  = SrcGrid->pr
  DstGrid    = addfile(pr_outname,"r")
  lat_dst    = DstGrid->lat
  lon_dst    = DstGrid->lon

  Opt                = True
  Opt@SrcFileName    = "src_SCRIP.nc"
  Opt@DstFileName    = "dst_SCRIP.nc"
  Opt@WgtFileName    = "NCEP_2_Rect.nc"
  Opt@DstGridLat     = lat_dst
  Opt@DstGridLon     = lon_dst
  Opt@ForceOverwrite = True
  Opt@SrcGridMask    = where(ismissing(bavaria_mask_pr),0,1)
  Opt@DstGridMask    = where(ismissing(gridmask2D),0,1)
  Opt@InterpMethod   = "neareststod"
  
  pr_regrid = ESMF_regrid(pr_source,Opt)
; pr_regrid@_FillValue = 1e20
  printVarSummary(pr_regrid)

  k->pr = pr_regrid
  
  ;-- Add some other attribute information we need to avoid LPJ-GUESS errors
  system("ncatted -a coordinates,pr,c,c,'lat lon' " +pr_outname)
  system("ncatted -a standard_name,lon,c,c,longitude " +pr_outname)
  system("ncatted -a standard_name,lat,c,c,latitude " +pr_outname)

  print("done")

;****************************************************************************************************
;************************ Write tas file ************************************************************

  tas  = g->tas(:,:,:)
  lati = g->lat
  loni = g->lon
  time = g->time

  invar = tas
  load "get_xy_limits.ncl"

  nlat   = targetgrid_dsizes(0)
  nlon   = targetgrid_dsizes(1)
  ntime  = dimsizes(time)

  lat_new = new((/nlat/),"double",0)
  lat_new@units = "degrees_north"
  lat_new@standard_name = "latitude"
  lat_new@long_name = "latitude"
  lon_new = new((/nlon/),"double",0)
  lon_new@units = "degrees_east"
  lon_new@standard_name = "longitude"
  lon_new@long_name = "longitude"
  time_new = new((/(ntime)/),"double",0)
  time_new@units = "days since 1971-01-01"

  do lt=0, nlat-1
     lat_new(lt) = min(lati) + (((max(lati)-min(lati))/(nlat-1))*lt)
  end do

  do ln=0, nlon-1
     lon_new(ln) = min(loni) + (((max(loni)-min(loni))/(nlon-1))*ln)
  end do

  do tt=0, ntime-1
     time_new(tt) = time(tt)
  end do

  tasNew = new((/ntime,nlat,nlon/),"double",0)
  tasNew!0="time"
  tasNew!1="lat"
  tasNew!2="lon"
  tasNew&time = time_new
  tasNew&lat = lat_new
  tasNew&lon = lon_new
  tasNew@standard_name = "air_temperature"
  tasNew@long_name = "near-surface temperature"
  tasNew@units = "degrees celsius"
  tasNew@_FillValue = default_fillvalue("double")
  tasNew@coordinates = "lat lon"

  outname = "tas_out_85.nc"
  system("rm -rf "+outname)
  l = addfile(outname,"c")
  l->tas = tasNew

  ;-- Write .nc file with rotated coordinates reprojected to flat map
  print("Writing tas file...")

  tas_new = l->tas(:,:,:)

  do tt=0, ntime-1
    do nln=0, nlon-1
      do ln=x_minlim, x_maxlim
        if (ln .eq. (nln + x_minlim))
          do nlt=0, nlat-1
            do lt=y_minlim, y_maxlim
              if (lt .eq. (nlt + y_minlim))
                tas_new(tt,nlt,nln) = (/tas(tt,lt,ln)/)
              end if
            end do
          end do
        end if
      end do
    end do
  end do

  l->tas = tas_new

  print("tas file written")
  print("regridding...")
  
  ; Create mask

  tasMask = new((/nlat,nlon/),"double",0)
  tasMask!0="lat"
  tasMask!1="lon"
  tasMask&lat = lat_new
  tasMask&lon = lon_new
    
  l->tasMask = tasMask
  tmask = l->tas  
  tas_msk = l->tasMask(:,:)

  do lt=0, nlat-1
    do ln=0, nlon-1 
      tas_msk(lt,ln) = where(.not.ismissing(tmask(0,lt,ln)),1,0)
    end do 
  end do
  
  l->tasMask = tas_msk
  bavaria_mask_tas = l->tasMask

  ; Regrid the data from source grid to new destination grid
  ; Assign output file name

  ;-- Create output file and populate with lat/lon dummy array
  tas_mask = i->mask
  system("rm -rf "+tas_outname)
  m = addfile(tas_outname,"c")
  m->tas = tas_mask  

  ;-- Create 2D mask
  gridmask2D = i->mask(0,:,:)

  SrcGrid    = addfile(outname,"r")
  tas_source = SrcGrid->tas
  DstGrid    = addfile(tas_outname,"r")
  lat_dst    = DstGrid->lat
  lon_dst    = DstGrid->lon

  Opt                = True
  Opt@SrcFileName    = "src_SCRIP.nc"
  Opt@DstFileName    = "dst_SCRIP.nc"
  Opt@WgtFileName    = "NCEP_2_Rect.nc"
  Opt@DstGridLat     = lat_dst
  Opt@DstGridLon     = lon_dst
  Opt@ForceOverwrite = True
  Opt@SrcGridMask    = where(ismissing(bavaria_mask_pr),0,1)
  Opt@DstGridMask    = where(ismissing(gridmask2D),0,1)
  Opt@InterpMethod   = "neareststod"

  tas_regrid = ESMF_regrid(tas_source,Opt)
; tas_regrid@_FillValue = 1e20
  printVarSummary(tas_regrid)

  m->tas = tas_regrid

  ;-- Add some other attribute information we need to avoid LPJ-GUESS errors
  system("ncatted -a coordinates,tas,c,c,'lat lon' " +tas_outname)
  system("ncatted -a standard_name,lon,c,c,longitude " +tas_outname)
  system("ncatted -a standard_name,lat,c,c,latitude " +tas_outname)

  print("done")

;****************************************************************************************************
;************************ Write rsds file ***********************************************************

  rsds = h->rsds(:,:,:)
  lati = h->lat
  loni = h->lon
  time = h->time

  invar = rsds
  load "get_xy_limits.ncl"

  nlat   = targetgrid_dsizes(0)
  nlon   = targetgrid_dsizes(1)
  ntime  = dimsizes(time)

  lat_new = new((/nlat/),"double",0)
  lat_new@units = "degrees_north"
  lat_new@standard_name = "latitude"
  lat_new@long_name = "latitude"
  lon_new = new((/nlon/),"double",0)
  lon_new@units = "degrees_east"
  lon_new@standard_name = "longitude"
  lon_new@long_name = "longitude"
  time_new = new((/(ntime)/),"double",0)
  time_new@units = "days since 1971-01-01"

  do lt=0, nlat-1
     lat_new(lt) = min(lati) + (((max(lati)-min(lati))/(nlat-1))*lt)
  end do

  do ln=0, nlon-1
     lon_new(ln) = min(loni) + (((max(loni)-min(loni))/(nlon-1))*ln)
  end do

  do tt=0, ntime-1
     time_new(tt) = time(tt)
  end do

  rsdsNew = new((/ntime,nlat,nlon/),"double",0)
  rsdsNew!0="time"
  rsdsNew!1="lat"
  rsdsNew!2="lon"
  rsdsNew&time = time_new
  rsdsNew&lat = lat_new
  rsdsNew&lon = lon_new
  rsdsNew@standard_name = "surface_downwelling_shortwave_flux_in_air"
  rsdsNew@long_name = "Bias-Adjusted Surface Downwelling Shortwave Radiation"
  rsdsNew@units = "W m-2"
  rsdsNew@_FillValue = default_fillvalue("double")
  rsdsNew@coordinates = "lat lon"

  outname = "rsds_out_85.nc"
  system("rm -rf "+outname)
  n = addfile(outname,"c")
  n->rsds = rsdsNew
  
  ;-- Write .nc file with rotated coordinates reprojected to flat map  
  print("Writing rsds file...")

  rsds_new = n->rsds(:,:,:)

  do tt=0, ntime-1
    do nln=0, nlon-1
      do ln=x_minlim, x_maxlim
        if (ln .eq. (nln + x_minlim))
          do nlt=0, nlat-1
            do lt=y_minlim, y_maxlim
              if (lt .eq. (nlt + y_minlim))
                rsds_new(tt,nlt,nln) = (/rsds(tt,lt,ln)/)
              end if
            end do
          end do
        end if
      end do
    end do
  end do
 
  n->rsds = rsds_new
  
  print("rsds file written")
  print("regridding...")
  
  ; Create mask

  rsdsMask = new((/nlat,nlon/),"double",0)
  rsdsMask!0="lat"
  rsdsMask!1="lon"
  rsdsMask&lat = lat_new
  rsdsMask&lon = lon_new

  n->rsdsMask = rsdsMask
  rmask = n->rsds
  rsds_msk = n->rsdsMask(:,:)

  do lt=0, nlat-1
    do ln=0, nlon-1
      rsds_msk(lt,ln) = where(.not.ismissing(rmask(0,lt,ln)),1,0)
    end do
  end do

  n->rsdsMask = rsds_msk
  bavaria_mask_rsds = n->rsdsMask

  ; Regrid the data from source grid to new destination grid
  ; Assign output file name

  ;-- Create output file and populate with lat/lon dummy array
  rsds_mask = i->mask
  system("rm -rf "+rsds_outname)
  o = addfile(rsds_outname,"c")
  o->rsds = rsds_mask

  ;-- Create 2D mask
  gridmask2D = i->mask(0,:,:)

  SrcGrid     = addfile(outname,"r")
  rsds_source = SrcGrid->rsds
  DstGrid     = addfile(rsds_outname,"r")
  lat_dst     = DstGrid->lat
  lon_dst     = DstGrid->lon

  Opt                = True
  Opt@SrcFileName    = "src_SCRIP.nc"
  Opt@DstFileName    = "dst_SCRIP.nc"
  Opt@WgtFileName    = "NCEP_2_Rect.nc"
  Opt@DstGridLat     = lat_dst
  Opt@DstGridLon     = lon_dst
  Opt@ForceOverwrite = True
  Opt@SrcGridMask    = where(ismissing(bavaria_mask_pr),0,1)
  Opt@DstGridMask    = where(ismissing(gridmask2D),0,1)
  Opt@InterpMethod   = "neareststod"

  rsds_regrid = ESMF_regrid(rsds_source,Opt)
; rsds_regrid@_FillValue = 1e20
  printVarSummary(rsds_regrid)

  o->rsds = rsds_regrid

  ;-- Add some other attribute information we need to avoid LPJ-GUESS errors
  system("ncatted -a coordinates,rsds,c,c,'lat lon' " +rsds_outname)
  system("ncatted -a standard_name,lon,c,c,longitude " +rsds_outname)
  system("ncatted -a standard_name,lat,c,c,latitude " +rsds_outname)

  print("done")

;****************************************************************************************************
  
  ;-- Clean up files created during ESMF regridding

  system("rm -rf "+"src_SCRIP.nc")
  system("rm -rf "+"dst_SCRIP.nc")
  system("rm -rf "+"PET0.RegridWeightGen.Log")  
  system("rm -rf "+"NCEP_2_Rect.nc")    

end
