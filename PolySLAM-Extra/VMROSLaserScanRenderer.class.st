Class {
	#name : #VMROSLaserScanRenderer,
	#superclass : #VMFigureRenderer,
	#instVars : [
		'points'
	],
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #converting }
VMROSLaserScanRenderer >> fromMsg: aMsg [
	"note: this method ignores the transformation and creates the pointcloud in the local frame of the sensor"
	| angle angleInc ranges dataCount |
	
	angle := aMsg angle_min.
	angleInc := aMsg angle_increment.
	ranges := aMsg ranges.
	dataCount := aMsg ranges size.
	
	1 to: dataCount do: [ :i |
		| dist point |
		dist := ranges at: i.
		
		"note: isFinite also checks if the number is NaN, isInfinite does not"
		dist isFinite ifTrue: [
			point := Point x: (((angle) cos negated) * dist) y: (((angle) sin) * dist).
			points add: point.
		].
		
		angle := angle + angleInc.
	].

]

{ #category : #initialization }
VMROSLaserScanRenderer >> initialize [
	super initialize.
	points := OrderedCollection new.
]

{ #category : #rendering }
VMROSLaserScanRenderer >> renderOn: aCanvas [

	"render the points from the laser scanner in red"
	self renderOn: aCanvas pointCollection: points color: Color red.
	
	"render the sensor center in white"
	self renderPoint: 0@0 radius: 1.2 * lineWidth in: aCanvas color: Color white.
	

]
