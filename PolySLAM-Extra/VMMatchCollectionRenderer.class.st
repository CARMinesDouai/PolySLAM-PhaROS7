Class {
	#name : #VMMatchCollectionRenderer,
	#superclass : #VMBaseRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #rendering }
VMMatchCollectionRenderer >> renderOn: aCanvas [
	| colorFirst colorSecond |
	colorFirst := color slightlyLighter.
	colorSecond := color slightlyDarker.
	model do: [ :pair |
		((pair first isNotNil) and: pair second isNotNil) ifTrue: [
			self renderPoint: pair first radius: lineWidth on: aCanvas color: (colorFirst shiftHue: -60).
			self renderPoint: pair second radius: lineWidth on: aCanvas color: (colorSecond shiftHue: 60).
			
			self renderStyledLineSegFrom: pair first to: pair second on: aCanvas color: color
		].
	].
Color
]
