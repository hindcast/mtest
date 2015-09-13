;;.............................................................................
;;.............................................................................
;; NCL Graphics: 
;;.............................................................................
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_LIB/ncarg/nclscripts/csm/contributed.ncl"

begin

;;.............................................................................
;; getenv
;;.............................................................................

  vbase = getenv("vbase") 
  fdate = getenv("fdate") ;; 2012-07-${dd}
  edate = getenv("edate") ;; 201207${dd}
  prun  = getenv("prun")  ;; ${prun}
  pout  = getenv("pout")  ;; ${pout}
  pint  = getenv("pint")  ;; ${pint}
  runid = getenv("runid") ;; EXP004
  expid = getenv("expid") ;; run_cesm12_mam3_1.9x2.5
  ilt   = stringtointeger(getenv("ilt"))    ;; UTC 00:00 local time index  
  latname = getenv("latname")   ;; "LAT_10n_to_60n"  
  lonname = getenv("lonname")   ;; "LON_200e_to_359e" 

;;.............................................................................
;; setup varname
;;.............................................................................

  vname  = vbase + "_" + lonname + "_" + latname 
  vnum   = 1
  vtype  = "normal"

  if(vbase.eq."FSNTC_RF") then 
     vnt1 = "FSNTC"
     vnt2 = "FSNTC_d1"
     vname1 = vnt1 + "_" + lonname + "_" + latname
     vname2 = vnt2 + "_" + lonname + "_" + latname
     vnum  = 2
     vtype  = "forcing"
  end if 

  fna = prun + "/" + expid + "_" + runid + "/" + runid + ".cam.h1." + fdate + "-00000.nc"

  print(" ")
  print(" ")
  print("..................................................................")
  print(" ")
  print(" ")
  print(" file name : "+fna)
  print(" ")
  print(" ")

  fngrid = pint + "/gridarea.nc"
  fgrid = addfile(fngrid,"r")
  gridarea = fgrid->cell_area
  
;;.............................................................................
;; Open netCDF file and read in dimensions
;;.............................................................................

  fla = addfile(fna,"r")

  lev   = fla->lev
  lat   = fla->$latname$
  lon   = fla->$lonname$


  if(vnum.eq.1) then
     vv = fla->$vname$
  end if

  if(vnum.eq.2) then
     vv1 = fla->$vname1$
     vv2 = fla->$vname2$
     vv  = vv1
     if(vtype.eq."forcing") then 
        vv  = vv1 - vv2
     else
        vv  = vv1 + vv2
     end if
     delete(vv1)
     delete(vv2)
  end if

  if(vnum.eq.3) then
     vv1 = fla->$vname1$
     vv2 = fla->$vname2$
     vv3 = fla->$vname3$
     vv  = vv1
     vv  = vv1 + vv2 + vv3
     delete(vv1)
     delete(vv2)
     delete(vv3)
  end if


;;.............................................................................
;; local time index 
;;.............................................................................


  ilt00 = ilt 
  ilt06 = ilt + 6  
  ilt12 = ilt + 12 
  ilt18 = ilt + 18 

  va    = vv(ilt00,:,:) 
  vb    = vv(ilt06,:,:) 
  vc    = vv(ilt12,:,:) 
  vd    = vv(ilt18,:,:) 

  nlev  = dimsizes(lev)                           
  nlat  = dimsizes(lat)
  nlon  = dimsizes(lon)

  print(" ") 
  print("nlev "+sprinti("%7.2i",nlev))
  print("nlat "+sprinti("%7.2i",nlat))
  print("nlon "+sprinti("%7.2i",nlon))
  print(" ") 
  print(" ") 

;;.............................................................................
;; read in variables & create plot
;;.............................................................................

  fno = pout + "/" + vbase+"_"+fdate+".nc" 

  system("rm "+fno) 

  flo = addfile(fno,"c") 

  flo->va=va 
  flo->vb=vb 
  flo->vc=vc 
  flo->vd=vd 

end

