;*******************************************
begin
;*******************************************

  lat_size = dimsizes(lati(:,0))
  lon_size = dimsizes(loni(0,:))

  lat_range = new((/lon_size/),"integer",0)
  lon_range = new((/lat_size/),"integer",0)

  do lns=0, lon_size-1
    if(all(ismissing(invar(0,:,lns))))
      lat_range(lns) = 100000000
    else
      lat_range(lns) = lns
    end if
  end do

  x_minlim = min(lat_range)
  if(x_minlim.eq.1)
    x_minlim = 0
  end if
  print(x_minlim)

  do lns=0, lon_size-1
    if(all(ismissing(invar(0,:,lns))))
      lat_range(lns) = -100000000
    else
      lat_range(lns) = lns
    end if
  end do

  x_maxlim = max(lat_range)
  print(x_maxlim)

  do lts=0, lat_size-1
    if(all(ismissing(invar(0,lts,:))))
      lon_range(lts) = 100000000
    else
      lon_range(lts) = lts
    end if
  end do

  y_minlim = min(lon_range)
  if(y_minlim.eq.1)
    y_minlim = 0
  end if
  print(y_minlim)

  do lts=0, lat_size-1
    if(all(ismissing(invar(0,lts,:))))
      lon_range(lts) = -100000000
    else
      lon_range(lts) = lts
    end if
  end do

  y_maxlim = max(lon_range)
  print(y_maxlim)

end 
