Class {
	#name : #PSInflateColinearProbability,
	#superclass : #PSProbability,
	#instVars : [
		'outlier'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #initialization }
PSInflateColinearProbability >> initialize [
	super initialize.
	outlier := 0.05. "5mm"
	
]

{ #category : #accessing }
PSInflateColinearProbability >> outlier [
	^ outlier
]

{ #category : #accessing }
PSInflateColinearProbability >> outlier: anObject [
	outlier := anObject
]

{ #category : #probability }
PSInflateColinearProbability >> probability [
	|pair line|
	lineA chain = lineB chain ifTrue:[^ 0].
	pair := self farestVertices.
	
	(pair value first dist: pair value second) > (lineA length + (lineB length))
		ifTrue:[^0].
	line := lineA value asVMLine.
	(line distanceToPoint: lineB value pointA) > self outlier
		ifTrue:[^ 0].
	(line distanceToPoint: lineB value pointB) > self outlier
		ifTrue:[^ 0].
	^ 1
]
