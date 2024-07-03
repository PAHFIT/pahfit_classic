;+
; NAME:
;
;   PAHFIT_SPLINE
;
; PURPOSE:
;
;   Recover the PAH strengths by fitting cubic splines to relatively
;   clean sections of continuum.
;
; CATEGORY:
;
;   Spectral Fitting
;
; CALLING SEQUENCE:
;
;   splfit=pahfit_spline(lam,flux,[/PLOT,/OVERPLOT])
;
; INPUTS:
;
;   lam: The wavelength in um.
;
;   flux: The flux in MJy/sr (or another suitably scaled f_nu unit).
;
; KEYWORD PARAMETERS:
;
;   PLOT: Plot the fitted splines.
;
;   OVERPLOT: Don't create a new plot when plotting.
;
; OUTPUTS:
;
;   splfit: The integrated power in the 4 main PAH bands: 6.2um,
;      7.7um, 8.6um, and 11.3um.  Units if W/m^2/sr (assuming the
;      input flux units are MJy/sr).
;
; RESTRICTIONS:
;
;   The passed spectrum must be in the rest frame, with redshift
;   already removed.  
;
; NOTE:
;
;   Cubic splines are fit to relatively clean section of the
;   continuum, following the methods of H. Spoon and E. Peeters (XXX
;   ref).
;
; MODIFICATION HISTORY:
;
;  2005-08-12 (JD Smith): Written.
;-

function pahfit_spline,lambda,intensity,PLOT=plot,OVERPLOT=oplot,_EXTRA=e
  tvlct,[0b,255b,230b],[200b,0b,165b],[0b,0b,0b],1
  
  if keyword_set(plot) && ~keyword_set(oplot) then $
     plot,lambda,intensity/lambda,XRANGE=[5,14],/XSTYLE, $
          XTITLE='Rest Wavelength (!7l!Xm)', $
          THICK=2,CHARSIZE=1.5,YTITLE='!7k!Xf!D!7k!X!N'
  
  ;; Spline sets.  The exact points necessary can change slightly.
  spline_set=[ptr_new({spline_points:[5.5D,5.87D,6.75D,7.15D], $
                       features:[[1,2]]}), $ ;; 6.2
              ptr_new({spline_points:[5.87D,6.75D,7.15D,8.26D,8.97D, 9.98D],$
                       features:[[2,3],[3,4]]}),$ ;; 7.7, 8.6
              ptr_new({spline_points:[9.98D,10.7D,11.75D,12.2D], $
                       features:[[1,2]]})]   ;; 11.3
              
  for i=0,n_elements(spline_set)-1 do begin 
     spline_points=(*spline_set[i]).spline_points
     features=(*spline_set[i]).features
     inten=interpol(intensity,lambda,spline_points)
     spline=spline(spline_points,inten,lambda)
     col=i+1
     
     if keyword_set(plot) then begin 
        oplot,spline_points,inten/spline_points, $
              PSYM=4,COLOR=col,SYMSIZE=2.,THICK=2.5
        wh=where(lambda ge min(spline_points,MAX=spmx)-0.2 AND $
                 lambda le spmx+0.2,cnt)
        oplot,lambda[wh],spline[wh]/lambda[wh],COLOR=col,_EXTRA=e
     endif 
  
     n=n_elements(features)/2
  
     for j=0,n-1 do begin 
        wh=where(lambda ge spline_points[features[0,j]] AND $
                 lambda le spline_points[features[1,j]],cnt)
        if cnt eq 0 then continue
        for k=0,1 do $
           plots,spline_points[features[k,j]],!Y.CRANGE,LINESTYLE=1
        ;; Integrate nu,f_nu (f_nu in MJy/sr), Final Units W/m^2/sr
        this_f=int_tabulated(2.9979246D14/lambda[wh], $
                             intensity[wh]-spline[wh],/SORT)*1.D-20
        if n_elements(f) eq 0 then f=this_f else f=[f,this_f]
     endfor 
  endfor 
  
  ptr_free,spline_set
  return,f
end
