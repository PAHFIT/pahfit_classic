;+
; NAME:
;
;    PAHFIT_MAIN_FEATURE_POWER
;
; PURPOSE:
;
;    Compute the power of the main dust features from a decoded PAHFIT
;    structure.
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
;    mf_struct=pahfit_main_feature_power(pahfit_fit,lam_rest, flux,
;                                        flux_uncertainty)
;
; INPUTS:
;
;    pahfit_fit: The decoded fit parameter structure returned by
;       PAHFIT, or a vector of such structures.
; 
;    lam_rest: The rest frame wavelength, for estimating uncertainties
;       in situ, or an array of such with second dimension equal in
;       length to the total number of PAHFIT structures provided in
;       the first argument.
;
;    flux: The flux spectrum the fit corresponds to, as vector or
;       array (see lam_rest).
;
;    flux_uncertainty: The flux uncertainty the fit corresponds to, as
;       vector or array (see lam_rest).
;
; OUTPUT:
;
;    ms_struct: A structure (or vector of structures, matching the
;        dimension of PAHFIT_FIT) detailing parameters of the main
;        dust features, with the following tags:
;
;       NAME: The name of the feature or complex.
;
;       RANGE: The range of wavelengths over which (sub-)features were
;          combined.
;
;       STRENGTH: The integrated power of the feature complex (units:
;          W/m^2[/sr] for inputs of MJy[/sr]
;
;       STRENGTH_UNC: The statistical uncertainty in the strength.
;
;       STRENGTH_UNC_ALT: An alternate uncertainty formed by
;          quadrature summing the statistical errors over the profile.
;
;       STRENGTH_UNC_ALT_2: An alternate uncertainty found by
;          evaluating the standard deviation of the residuals between
;          data and model fit.;
;
; EXAMPLE:
;
;   mf=pahfit_main_feature_power([pahfit_struct1,pahfit_struct2])
;
; MODIFICATION HISTORY:
;
;  2006-02-12 (JD Smith): Written.
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


;; Pass a "dust_features" structure array.
function pahfit_main_feature_power,pahfit, lam_rest, flux, flux_uncertainty
  
  dust_features=pahfit.dust_features 
    
  ;; Main PAH features and blends (some overlap)
  features=[{name: '6.2um',range:[6.2,6.3]}, $
            {name: '7.7um Complex',range:[7.3,7.9]}, $
            {name: '8.3um',range:[8.3,8.4]}, $
            {name: '8.6um',range:[8.6,8.7]}, $
            {name: '11.3um Complex',range:[11.2,11.4]}, $
            {name: '12.0um',range:[11.9,12.1]}, $
            {name: '12.6um Complex',range:[12.6,12.7]}, $
            {name: '13.6um',range:[13.4,13.6]}, $
            {name: '14.2um',range:[14.1,14.2]}, $
            {name: '16.4um',range:[16.4,16.5]}, $
            {name:'17um Complex',range:[16.4,17.9]},$
            {name:'17.4um', range:[17.35,17.45]}]
  nf=n_elements(features) 

  dust_wav=dust_features[*,0].wavelength
  n=n_elements(pahfit) 
  for i=0,nf-1 do begin 
     wh=where(dust_wav ge features[i].range[0] AND $
              dust_wav le features[i].range[1],cnt)
     if cnt eq 0 then message,'No features found in range'
     
     unc_estimate1=dblarr(n,/NOZERO) 
     unc_estimate2=dblarr(n,/NOZERO) 
     strength=dblarr(n,/NOZERO)
     strength_unc=dblarr(n,/NOZERO)
     for j=0,n-1 do begin 
        strength[j]=pahfit_feature_strength_combine(pahfit[j], $
                                                    dust_features[wh,j], $
                                                    UNCERTAINTY=stunc)
        strength_unc[j]=stunc
        lam=lam_rest[*,j]

        ;;Estimate the uncertainty directly from the data:
        f=flux[*,j]
        f_unc=flux_uncertainty[*,j]
        profile=dblarr(n_elements(lam))
        for k=0,cnt-1 do begin 
           lam0=dust_features[wh[k],j].wavelength
           central_inten=dust_features[wh[k],j].wavelength
           frac_fwhm=dust_features[wh[k],j].fwhm
           profile+=pahfit_drude(lam,lam0,central_inten,frac_fwhm)
        endfor 
        profile/=max(profile)
        
        nu=(2.9979246D14/lam)   ;Hz
        dnu=abs(nu[1:*]-nu)     
        dnu=[dnu[0],dnu]
        ;; profile-weighted quadrature summed sigma over the range of
        ;; interest, W/m^2/sr
        whp=where(profile gt .1,pcnt)
        unc_estimate1[j]=1.D-20*sqrt(total(f_unc[whp]^2*dnu[whp]^2))
        
        f-=pahfit[j].final_fit
        ;; From the standard deviation of the fit residuals
        unc_estimate2[j]=sqrt(total(dnu[whp]^2))*stddev(f[whp])*1.D-20
     endfor 
     
     eqw=total(dust_features[wh,*].eqw,1,/NAN)
     
     st={name:features[i].name,range:features[i].range,strength:strength, $
         strength_unc:strength_unc,eqw:eqw,strength_unc_alt:unc_estimate1, $
         strength_unc_alt_2:unc_estimate2}
     if n_elements(all_dust) eq 0 then all_dust=st else $
        all_dust=[all_dust,st]
  endfor
  
  return,all_dust
end

