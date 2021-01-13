# Dynamic Network Strategies for SARS-CoV-2 Control on a Cruise Ship

This repository holds the source to code to reproduce the analysis featured in our SARS-CoV-2 transmission model on the Diamond Princess cruise ship in February/March 2020.

## Citation

> 2.	Jenness SM, Wilebrand KS, Malik AA, Lopman BA, Omer S. Modeling Dynamic Network Strategies for SARS-CoV-2 Control on a Cruise Ship. _Under Review._  [[Pre-Print]](https://doi.org/10.1101/2020.08.26.20182766)

<img src="https://github.com/EpiModel/COVID-CruiseShip/raw/master/analysis/Fig1.png">

## Abstract

SARS-CoV-2 outbreaks have occurred on several nautical vessels, driven by the high-density contact networks on these ships. Optimal strategies for prevention and control that account for realistic contact networks are needed. We developed a network-based transmission model for SARS-CoV-2 on the Diamond Princess outbreak to characterize transmission dynamics and to estimate the epidemiological impact of outbreak control and prevention measures. This model represented the dynamic multi-layer network structure of passenger-passenger, passenger-crew, and crew-crew contacts, both before and after the large-scale network lockdown imposed on the ship in response to the disease outbreak. Model scenarios evaluated variations in the timing of the network lockdown, reduction in contact intensity within the sub-networks, and diagnosis-based case isolation on outbreak prevention. We found that only extreme restrictions in contact patterns during network lockdown and idealistic clinical response scenarios could avert a major COVID-19 outbreak. Contact network changes associated with adequate outbreak prevention were the restriction of passengers to their cabins, with limited passenger-crew contacts. Clinical response strategies required for outbreak prevention included early mass screening with an ideal PCR test (100% sensitivity) and immediate case isolation upon diagnosis. Public health restrictions on optional leisure activities like these should be considered until longer-term effective solutions such as a COVID-19 vaccine become widely available.

<img src="https://github.com/EpiModel/COVID-CruiseShip/raw/master/analysis/Fig2.png">

## Model Code

These models are written and executed in the R statistical software language. To run these files, it is necessary to first install our epidemic modeling software, [EpiModel](http://epimodel.org/), and our extension package specifically for modeling SARS-CoV-2 transmission dynamics , [EpiModelCOVID](http://github.com/EpiModel/EpiModelCOVID).

This is accomplished with the `renv` package in R. First install `renv` (if you do not already have it installed) and run:

```r
renv::init()
```

in your project directory. Select the option to restore the package set set from the `renv.lock` file. Currently, this requires access to the `ARTnetData` package, which requires a limited access data use agreement due to the sensitive nature of those study data. Please contact the corresponding author for access. 

<img src="https://github.com/EpiModel/COVID-CruiseShip/raw/master/analysis/Fig3.png">
