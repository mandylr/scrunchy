% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{create_fce}
\alias{create_fce}
\title{Create a functional cell experiment (fce) object as a MultiAssayExperiment}
\usage{
create_fce(rna_data, functional_data, id_from_name = TRUE,
  id_delim = ".", id_fields = 2, adduct_positions = NULL)
}
\arguments{
\item{rna_data}{UMI count matrix}

\item{functional_data}{Functional count matrix}

\item{id_from_name}{Extract sample id from cell name (default = TRUE) If
false then the sample_id field will be populated with NA.}

\item{id_delim}{delimiter to split cell name (default = ".")}

\item{id_fields}{index(es) of fields to extract from name for determining
sample id from name (defaults to c(2))}

\item{adduct_positions}{optional data.frame with positions of first and
second adducts in each hairpin, must be a three column data.frame with the
first column named hairpin containing with entries that match the adducts
from haircut_data (i.e. Uracil from entry Uracil_1), a second column named
adduct_position1 with the first adduct position, and a third column named
adduct_position2 with the second adduct position}
}
\value{
fce object of class MultiAssayExperiment containing
SingleCellExperiments. mRNA data is stored in slot "sce", and functional
data is stored in slot "fsce"
}
\description{
Create a functional cell experiment (fce) object as a MultiAssayExperiment
}
