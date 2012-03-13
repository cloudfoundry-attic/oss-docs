# BOSH Technical Overview
© VMWare 2012

The BOSH Technical Overview is written in MultiMarkdown (MMD). If you want to install the MultiMarkdown tools, you can read about that here: [MultiMarkdown](https://github.com/fletcher/peg-multimarkdown) 

To create a PDF from a MMD document you need both MultiMarkdown and LaTeX on your system. You can read about how to do this here: [LaTeX Home Page](http://www.latex-project.org/)

If you are on a Mac, It is recommended that you install MultiMarkdown Composer from the Apple App Store, but any text editor will do.

You can create a nicely formatted PDF like this…

1. Download John Fletcher's MMD Latex Support files [here](https://github.com/fletcher/peg-multimarkdown-latex-support)
2. Install them here `~/Library/texmf/tex/latex/mmd` or on Unix here: `~/texmf/tex/latex/mmd`
3. Edit the mmd-article-begin-doc.tex file with:
	
		\begin{document}
		\title{\mytitle}
		\author{© \myauthor}
		\date{\relax}%TeX note: relax: null

4. At the top of your MMD document, create metadata such as:

		latex input:	mmd-article-header
		Title:	BOSH Technical Overview 
		Author:	VMware 2012 - Cloud Foundry
		Base Header Level:	2  
		LaTeX Mode:	memoir  
		latex input:        mmd-article-begin-doc
		latex footer:       mmd-memoir-footer

5. You can create a PDF from Markdown using the instructions on [John Fletcher's site](http://fletcherpenney.net/multimarkdown/) - or you can use MultiMarkdown Composer to Export to LaTeX, and then generate a PDF from there.



