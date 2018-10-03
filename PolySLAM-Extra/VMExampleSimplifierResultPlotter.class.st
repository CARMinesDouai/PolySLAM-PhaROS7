Class {
	#name : #VMExampleSimplifierResultPlotter,
	#superclass : #VMPlotter,
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #plotting }
VMExampleSimplifierResultPlotter >> plotOn: aProcess [
	| rect |
	
	rect := Rectangle point: -0.5@2.5 point: 4.5@0.
	
	plotInitStream
		nextPutAll: 'set ytics (1.0, 2.0)'; crlf;
		nextPutAll: 'set yrange [0.3:2.3]'; crlf.
	
	self plotArrowCollection: model.


]
