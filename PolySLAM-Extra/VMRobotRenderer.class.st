Class {
	#name : #VMRobotRenderer,
	#superclass : #VMElementRenderer,
	#instVars : [
		'fillColor',
		'showSensors'
	],
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMRobotRenderer >> centerPoint [
	^ self model position
	
]

{ #category : #'as yet unclassified' }
VMRobotRenderer >> fillColor [
	^fillColor.
]

{ #category : #'as yet unclassified' }
VMRobotRenderer >> fillColor: aColor [
	fillColor := aColor.
]

{ #category : #'as yet unclassified' }
VMRobotRenderer >> initialize [
	
	super initialize.
	
	color := Color r: 0.1 g: 0.1 b: 0.1.
	fillColor := Color r: 0.9 g: 0.9 b: 0.9.
	lineWidth := 0.05.
	
]

{ #category : #'as yet unclassified' }
VMRobotRenderer >> radius [
	^self model radius
]

{ #category : #'as yet unclassified' }
VMRobotRenderer >> renderOn: canvas [
		
	| top bottom path stroke |
		
	top := self centerPoint + (self radius@0).
	bottom := self centerPoint - (self radius@0).
	
	path := canvas createPath: [ :builder |
		builder 
			absolute; 
			moveTo: top;
			cwArcTo: bottom angle: Float pi;
			cwArcTo: top angle: Float pi.
	].
	
	canvas setPaint: fillColor.
	canvas drawShape: path.
	
	stroke := canvas setStrokePaint: self color.
	stroke width: self lineWidth.
	canvas drawShape: path.
	
	path := canvas createPath: [  :builder |
		builder
			absolute;
			moveTo: (self centerPoint);
			lineTo: (((self centerPoint) + (0 @ self radius) ) rotateBy: (self model orientation) about: (self centerPoint) )
	].
	canvas drawShape: path.
	
	showSensors ifTrue: [
		model sensors do: [ :sensor |
			(sensor asRenderableElement)
				lineWidth: (self lineWidth / 2);
				renderOn: canvas.
		].
	].
	
	"super renderOn: canvas"
]

{ #category : #'as yet unclassified' }
VMRobotRenderer >> showSensors: aBoolean [
	showSensors := aBoolean
]
