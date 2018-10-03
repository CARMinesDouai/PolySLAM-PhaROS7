Class {
	#name : #VMPointCloud2dRenderer,
	#superclass : #VMBaseRenderer,
	#instVars : [
		'sensorCenterColor'
	],
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #initialization }
VMPointCloud2dRenderer >> initialize [
	super initialize.
	sensorCenterColor := Color h: 280 s: 1.0 v: 1.0.
]

{ #category : #rendering }
VMPointCloud2dRenderer >> renderOn: aCanvas [
	
	model ifNil: [ ^self ].
	
	
	model points do: [ :aPoint |
		self renderFilledPoint: aPoint radius: lineWidth on: aCanvas color: color.
		self renderStyledLineSegFrom: model sensorCenter to: aPoint on: aCanvas color: color.
	].

	self renderFilledPoint: model sensorCenter radius: 2 * lineWidth on: aCanvas color: sensorCenterColor.
	self renderFilledPoint: model sensorCenter radius: lineWidth on: aCanvas color: sensorCenterColor.
	
]

{ #category : #accessing }
VMPointCloud2dRenderer >> sensorCenterColor [
	^ sensorCenterColor
]

{ #category : #accessing }
VMPointCloud2dRenderer >> sensorCenterColor: aColor [
	sensorCenterColor := aColor.
]
