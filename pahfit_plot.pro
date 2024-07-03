;+
; NAME:
;
;    PAHFIT_PLOT
;
; PURPOSE:
;
;    Plot the results of a PAHFIT decomposition.
;
; REFERENCE:
; 
;    Smith, J.D., Draine B.T., et al., ApJ, 2006, XXX, XXX
;
; CATEGORY:
;
;    IRS Spectral fitting, PAH Emission, Silicate
;
; CALLING SEQUENCE:
;
;    pahfit_plot, pahfit_fit, lambda, flux, [flux_uncertainty,
;       UNITS=, /NO_EXTINCTION, /FAST_PLOT, /BLACK, SCALE_FAC=, _EXTRA=]
;
; INPUTS:
;
;    pahfit_fit: The decoded fit parameter structure returned by
;       PAHFIT.
;    
;    lambda: The wavelength in microns, in the rest frame.
;
;    flux: The flux (or flux intensity), in whatever units is specified
;       by the UNITS keyword (default: MJy/sr).
;
; OPTIONAL INPUTS:
;
;    flux_uncertainty: The flux intensity uncertainty, in the same
;       units as FLUX.
;
; KEYWORD PARAMETERS:
;
;    UNITS: The units to use in the Y axis title (default MJy/sr).
;
;    NO_EXTINCTION: Do not plot the extinction effect and "Relative
;       Extinction" right axis.
;
;    FAST_PLOT: Plot the model at the same sampling as the input
;       LAMBDA vector, rather than on a smoother grid.
;
;    BLACK: Plot the model as black instead of green.
;
;    SCALE_FAC: A factor by which to scale the model (for instance to
;       change the units).
;    
;    _EXTRA: Any extra plotting keyword parameters.
;      
; RESTRICTIONS:
;
;   The passed spectrum must be in the rest frame.
;   
; EXAMPLE:
;
;   pahfit_plot,lam/(1+cz/3.e5),flux,flux_unc
;
; MODIFICATION HISTORY:
;
;  2005-07-01 (JD Smith): Written.
;
;-
;##############################################################################
;
; LICENSE
;
;  Copyright (C) 2005-2006 J.D. Smith
;
;  This file is part of PAHFIT.
;
;  PAHFIT is free software; you can redistribute it and/or modify it
;  under the terms of the GNU General Public License as published by
;  the Free Software Foundation; either version 2, or (at your option)
;  any later version.
;
;  PAHFIT is distributed in the hope that it will be useful, but
;  WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;  General Public License for more details.
;
;  You should have received a copy of the GNU General Public License
;  along with PAHFIT; see the file COPYING.  If not, write to the Free
;  Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
;  MA 02110-1301, USA.
;
;##############################################################################

pro pahfit_plot,decoded_params,lambda,intensity,errors,UNITS=units, $
                NO_EXTINCTION=next,FAST_PLOT=fp,BLACK=black, $
                SCALE_FAC=fac,WAVE_DIM=wd,_REF_EXTRA=e
  !P.PSYM=0
  device,get_decomposed=gd
  device,decomposed=0
  tvlct,[255b,255b,0b,0b,160b,100b], $
        [0b,  0b,200b,0b,32b,100b], $
        [255b,0b,0b,255b,240b,100b],1
  if n_elements(units) eq 0 then units="MJy/sr"
  
  if !P.FONT eq 0 then begin 
     um='!Mm!Xm'
     nu='!Mn!X'
     lam='!Ml!X'
  endif else begin 
     um='!7l!Xm'
     nu='!7m!X'
     lam='!7k!X'
  endelse 
  
  rat=intensity/lambda
  if n_elements(fac) ne 0 then rat*=fac
  
  plot,lambda,rat,XTITLE='Wavelength ('+um+')', $
       YTITLE='I!D'+nu+'!N/'+lam+' ('+units+'/'+um+')',PSYM=6, XSTYLE=1, $
       YSTYLE=keyword_set(next)?0:8, $
       CHARSIZE=1.3,_EXTRA=e
  if n_elements(errors) ne 0 then begin 
     low=(intensity-errors)/lambda
     high=(intensity+errors)/lambda
     if n_elements(fac) ne 0 then begin 
        low*=fac
        high*=fac
     endif 
     errplot,lambda,low,high
  endif 
  
  
  if keyword_set(fp) then lam=lambda else begin 
     if n_elements(wd) eq 0 then wd=1500
     mn=min(lambda,MAX=mx)
     lam=mn+findgen(wd)/(wd-1.)*(mx-mn)
  endelse 
  
  yfit=pahfit_components(lam,decoded_params,DUST_CONTINUUM=dusts, $
                         TOTAL_DUST_CONTINUUM=dust_tot,STARLIGHT=stars, $
                         DUST_FEATURES=features, $
                         TOTAL_DUST_FEATURES=features_tot, $
                         LINES=lines,TOTAL_LINES=lines_tot, $
                         EXTINCTION_FAC=ext,_EXTRA=e)
  
  if ~keyword_set(next) then begin 
     oplot,lam,!Y.CRANGE[0]+(!Y.CRANGE[1]-!Y.CRANGE[0])/1.05*ext, $
           LINESTYLE=1,THICK=2,_EXTRA=e
     axis,YAXIS=1,YRANGE=[0,1.05],/YSTYLE,YTITLE='Relative Extinction', $
          CHARSIZE=1.3,_EXTRA=e
  endif 
  
  rat=stars/lam
  if n_elements(fac) ne 0 then rat*=fac
  oplot,lam,rat,COLOR=1,THICK=2
  for i=0,(size(dusts,/DIMENSIONS))[1]-1 do begin 
     rat=dusts[*,i]/lam
     if n_elements(fac) ne 0 then rat*=fac
     oplot,lam,rat,COLOR=2,THICK=2,LINESTYLE=0,_EXTRA=e
  endfor 
  
  cont=dust_tot+stars
  
  for i=0,(size(features,/DIMENSIONS))[1]-1 do begin 
     rat=(cont+features[*,i])/lam
     if n_elements(fac) ne 0 then rat*=fac
     oplot,lam,rat,COLOR=4,LINESTYLE=0,_EXTRA=e
  endfor 
  
  for i=0,(size(lines,/DIMENSIONS))[1]-1 do begin 
     rat=(cont+lines[*,i])/lam
     if n_elements(fac) ne 0 then rat*=fac
     oplot,lam,rat,COLOR=5,LINESTYLE=0,_EXTRA=e
  endfor 
  
  rat=cont/lam
  if n_elements(fac) ne 0 then rat*=fac  
  oplot,lam,rat,COLOR=6,THICK=4,_EXTRA=e
  
  rat=yfit/lam
  if n_elements(fac) ne 0 then rat*=fac  
  oplot,lam,rat,THICK=keyword_set(black)?2:3,COLOR=keyword_set(black)?0:3, $
        _EXTRA=e
  device,decomposed=gd
end
