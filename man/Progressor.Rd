% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Progressor.R
\name{Progressor}
\alias{Progressor}
\title{Progressor}
\description{
Wraps \code{progressr::progressor()} function and stores current progress.
}
\section{Public fields}{
\if{html}{\out{<div class="r6-fields">}}
\describe{
\item{\code{progressor}}{(\code{progressr::progressor()}).}

\item{\code{max_steps}}{(\code{integer(1)}).}

\item{\code{current_steps}}{(\code{integer(1)}).}

\item{\code{unit}}{(\code{character(1)}).}
}
\if{html}{\out{</div>}}
}
\section{Methods}{
\subsection{Public methods}{
\itemize{
\item \href{#method-Progressor-new}{\code{Progressor$new()}}
\item \href{#method-Progressor-update}{\code{Progressor$update()}}
\item \href{#method-Progressor-clone}{\code{Progressor$clone()}}
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-Progressor-new"></a>}}
\if{latex}{\out{\hypertarget{method-Progressor-new}{}}}
\subsection{Method \code{new()}}{
Creates a new instance of this \link[R6:R6Class]{R6} class.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{Progressor$new(progressor, unit)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{progressor}}{(\code{progressr::progressor()})\cr
Progressor function.}

\item{\code{unit}}{(\code{character(1)})\cr
Unit of progress.}
}
\if{html}{\out{</div>}}
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-Progressor-update"></a>}}
\if{latex}{\out{\hypertarget{method-Progressor-update}{}}}
\subsection{Method \code{update()}}{
Updates \code{progressr::progressor()} with current steps.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{Progressor$update(terminator, archive)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{terminator}}{(\link{Terminator}).}

\item{\code{archive}}{(\link{Archive}).}
}
\if{html}{\out{</div>}}
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-Progressor-clone"></a>}}
\if{latex}{\out{\hypertarget{method-Progressor-clone}{}}}
\subsection{Method \code{clone()}}{
The objects of this class are cloneable with this method.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{Progressor$clone(deep = FALSE)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{deep}}{Whether to make a deep clone.}
}
\if{html}{\out{</div>}}
}
}
}
