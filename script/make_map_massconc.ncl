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

  if(vbase.eq."bc") then 
     vnt = "bc_a1" 
     vname = vnt + "_" + lonname + "_" + latname 
     vnum  = 1
  end if 

  if(vbase.eq."pom") then
     vnt = "pom_a1"
     vname = vnt + "_" + lonname + "_" + latname
     vnum  = 1
  end if

  if(vbase.eq."dst") then 
     vnt1 = "dst_a1" 
     vnt2 = "dst_a3" 
     vname1 = vnt1 + "_" + lonname + "_" + latname 
     vname2 = vnt2 + "_" + lonname + "_" + latname 
     vnum = 2 
  end if 

  if(vbase.eq."soa") then
     vnt1 = "soa_a1"
     vnt2 = "soa_a2"
     vname1 = vnt1 + "_" + lonname + "_" + latname
     vname2 = vnt2 + "_" + lonname + "_" + latname
     vnum = 2
  end if

  if(vbase.eq."ncl") then 
     vnt1 = "ncl_a1" 
     vnt2 = "ncl_a2" 
     vnt3 = "ncl_a3" 
     vname1 = vnt1 + "_" + lonname + "_" + latname 
     vname2 = vnt2 + "_" + lonname + "_" + latname 
     vname3 = vnt3 + "_" + lonname + "_" + latname 
     vnum = 3 
  end if 

  if(vbase.eq."so4") then
     vnt1 = "so4_a1"
     vnt2 = "so4_a2"
     vnt3 = "so4_a3"
     vname1 = vnt1 + "_" + lonname + "_" + latname
     vname2 = vnt2 + "_" + lonname + "_" + latname
     vname3 = vnt3 + "_" + lonname + "_" + latname
     vnum = 3
  end if

  tname  = "T_"  + lonname + "_" + latname
  pname  = "PS_" + lonname + "_" + latname

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
     vv  = vv1 + vv2 
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

  st    = fla->$tname$
  ps    = fla->$pname$
  hyam  = fla->hyam
  hybm  = fla->hybm

  nk = dimsizes(hyam)

  ;;.............................................................................
  ;; pressure
  ;;.............................................................................

  pp = st

  do ik = 0,nk-1
     pp(:,ik,:,:) = doubletofloat(hyam(ik))*100000. + doubletofloat(hybm(ik)) * ps(:,:,:)
  end do

  ;;.............................................................................
  ;; #/kg -> ug/m3
  ;;.............................................................................

  R = 8.3143

  vv = vv * pp * 29. / ( R * st * 1000. ) * 1.e9


  ;;.............................................................................
  ;; local time index 
  ;;.............................................................................

  ilt00 = ilt 
  ilt06 = ilt + 6  
  ilt12 = ilt + 12 
  ilt18 = ilt + 18 

  va    = vv(ilt00,29,:,:) 
  vb    = vv(ilt06,29,:,:) 
  vc    = vv(ilt12,29,:,:) 
  vd    = vv(ilt18,29,:,:) 

  nlev  = dimsizes(lev)                           
  nlat  = dimsizes(lat)
  nlon  = dimsizes(lon)

  print(" ") 
  print("nlev "+sprinti("%7.2i",nlev))
  print("nlat "+sprinti("%7.2i",nlat))
  print("nlon "+sprinti("%7.2i",nlon))
  print(" ") 
  print(" ") 

;;......................................................................................
;; read in variables & create plot
;;......................................................................................

  fno = pout + "/" + vbase+"_surf_"+fdate+".nc" 

  print(" ")
  print(" file name : "+fno)

  system("rm "+fno) 

  flo = addfile(fno,"c") 

  flo->va=va 
  flo->vb=vb 
  flo->vc=vc 
  flo->vd=vd 

end

