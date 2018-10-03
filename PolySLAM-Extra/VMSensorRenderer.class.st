Class {
	#name : #VMSensorRenderer,
	#superclass : #VMFigureRenderer,
	#instVars : [
		'useGlobalFrame',
		'rotationAngle'
	],
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMSensorRenderer >> centerPoint [
	^ self model centerPoint

]

{ #category : #'as yet unclassified' }
VMSensorRenderer >> initialize [
	super initialize.
	
	useGlobalFrame := true.
]

{ #category : #'as yet unclassified' }
VMSensorRenderer >> radius [
	 ^0.1.
]

{ #category : #'as yet unclassified' }
VMSensorRenderer >> renderOn: canvas [
		
	| top bottom path |
		
	top := self centerPoint + (self radius@0).
	bottom := self centerPoint - (self radius@0).
	
	path := canvas createPath: [ :builder |
		builder 
			absolute; 
			moveTo: top;
			cwArcTo: bottom angle: Float pi;
			cwArcTo: top angle: Float pi.
	].
	
	canvas setPaint: color.
	canvas drawShape: path.
	

]

{ #category : #'as yet unclassified' }
VMSensorRenderer >> rotateBy: angle [
	rotationAngle := angle.
]

{ #category : #'as yet unclassified' }
VMSensorRenderer >> useGlobalFrame: aBoolean [
	useGlobalFrame := aBoolean.
]
