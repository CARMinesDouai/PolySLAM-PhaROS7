Extension { #name : #Color }

{ #category : #'*PolySLAM-Core' }
Color class >> byInteger: anInt [
	| h |
	h := (anInt * 41.0) \\ 360.
	"Transcript show: 'Color byInteger: ', anInt printString, ' (h=', h printString, ')'; cr."
	
	^(self h: h s: 1.0 v: 1.0)
]

{ #category : #'*PolySLAM-Core' }
Color >> shiftHue: aNumber [ "angle in degree"
	| h s v |
	h := (self hue + aNumber) \\ 360.0.
	s := self saturation.
	v := self brightness.
	
	^ self species h: h s: s v: v
]
