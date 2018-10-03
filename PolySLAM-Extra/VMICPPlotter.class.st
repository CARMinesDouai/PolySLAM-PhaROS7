Class {
	#name : #VMICPPlotter,
	#superclass : #VMPlotter,
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #'as yet unclassified' }
VMICPPlotter >> plotOn: aSubProcess [
	
	aSubProcess stdinStream
		nextPutAll: ''.
		
	"process stdinStream
		nextPutAll: 'plot ''-'' using 1:2 with points, "" using 1:2 with lines';
		nextPutAll: crlf;
		nextPutAll: data;
		nextPutAll: 'e', crlf;
		nextPutAll: '0 ', medianError printString, crlf;
		nextPutAll: inlier size printString, ' ', medianError printString, crlf;
		nextPutAll: 'e', crlf;
	"

]
