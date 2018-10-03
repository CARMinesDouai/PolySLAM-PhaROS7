Class {
	#name : #VMICPThresholdPlotter,
	#superclass : #VMPlotter,
	#instVars : [
		'colorIndex'
	],
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #initialization }
VMICPThresholdPlotter >> initialize [
	super initialize.
	colorIndex := 1.
]

{ #category : #plotting }
VMICPThresholdPlotter >> plotOn: aSubProcess [

]

{ #category : #plotting }
VMICPThresholdPlotter >> plotStartThreshold: startThreshold falloff: falloff maxIterations: maxIterations [
	| icp points title |
	icp := (VMVectorICP new)
		outlierStartThreshold: startThreshold;
		outlierThresholdFalloff: falloff;
		maxIterations: maxIterations;
		yourself.
	points := OrderedCollection new.
	title := startThreshold printString, '/',falloff printString, '/', maxIterations printString.
	
	1 to: maxIterations do: [ :i |
		points add: i @ (icp computeOutlierThreshold: i).
	].
	
	"self plotConnectedPoints: points extra: 'lt -1 pi -4 pt 6 title ''', title, ''''."
	self plotConnectedPoints: points extra: 'lt rgb ''#', (Color byInteger: colorIndex) asHexString ,''' pi -4 pt 6 title ''', title, ''''.
	colorIndex := colorIndex + 1.

]
