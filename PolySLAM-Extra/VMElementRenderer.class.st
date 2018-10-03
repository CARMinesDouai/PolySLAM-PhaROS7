Class {
	#name : #VMElementRenderer,
	#superclass : #Object,
	#instVars : [
		'model',
		'color',
		'label',
		'showLabel',
		'font',
		'textColor',
		'textScale',
		'dashed',
		'lineWidth',
		'dashStyle'
	],
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMElementRenderer class >> model: aModel [
	^(self new)
		model: aModel.
]

{ #category : #converting }
VMElementRenderer >> asRenderableElement [
	^ self
]

{ #category : #accessing }
VMElementRenderer >> beDashed [
	"self dashed: true"
	dashStyle := #( "fill" 2.0  "gap" 1.0 ).
]

{ #category : #accessing }
VMElementRenderer >> beDotted [
	"dashStyle := #(  lineWidth  lineWidth )."
	dashStyle := { "fill" lineWidth.  "gap" lineWidth }.
	
]

{ #category : #accessing }
VMElementRenderer >> beSolid [
	dashStyle := nil.
]

{ #category : #accessing }
VMElementRenderer >> bounds [
	"expected to return a Rectangle that represents the boundaries of the model.
	if the object has no rectangle, nil should be returned"
	
	model ifNotNil: [ ^model bounds ].
	
	^ nil
]

{ #category : #accessing }
VMElementRenderer >> color [
	^ color
]

{ #category : #accessing }
VMElementRenderer >> color: anObject [
	color := anObject.
	self textColor: anObject
]

{ #category : #accessing }
VMElementRenderer >> dashStyle [
	^dashStyle.
]

{ #category : #accessing }
VMElementRenderer >> dashStyle: styleOrNil [
	dashStyle := styleOrNil.
]

{ #category : #accessing }
VMElementRenderer >> dashed [
	^ dashed
]

{ #category : #accessing }
VMElementRenderer >> dashed: anObject [
	dashed := anObject
]

{ #category : #initialization }
VMElementRenderer >> initialize [
	super initialize.
	color := Color magenta.
	textColor := color.
	label := ''.
	font := LogicalFont familyName: 'Arial' pointSize: 20.
	textScale := 0.05.
	lineWidth := 0.05.
	dashed := false.
	showLabel := true
	
]

{ #category : #accessing }
VMElementRenderer >> label [
	^ label
]

{ #category : #accessing }
VMElementRenderer >> label: anObject [
	label := anObject
]

{ #category : #accessing }
VMElementRenderer >> labelPosition [
	^ self subclassResponsibility 
]

{ #category : #accessing }
VMElementRenderer >> lineWidth [
	^lineWidth.

]

{ #category : #accessing }
VMElementRenderer >> lineWidth: anObject [
	lineWidth := anObject
]

{ #category : #accessing }
VMElementRenderer >> model [
	^ model
]

{ #category : #accessing }
VMElementRenderer >> model: anObject [
	model := anObject
]

{ #category : #rendering }
VMElementRenderer >> renderLabel: canvas [
	(self showLabel and: [self label notNil]) ifTrue: [
		self renderString: self label at: self labelPosition in: canvas
	]

]

{ #category : #rendering }
VMElementRenderer >> renderOn: canvas [
	self renderLabel: canvas.
]

{ #category : #'drawing support' }
VMElementRenderer >> renderString: aString at: aPoint in: canvas [
	self renderString: aString at: aPoint in: canvas color: (self textColor).

]

{ #category : #'drawing support' }
VMElementRenderer >> renderString: aString at: aPoint in: canvas color: customColor [
	canvas setFont: font.
	canvas setPaint: customColor.
			
	canvas pathTransform restoreAfter: [
		canvas pathTransform 
			translateX: (aPoint x - ((self textScale*(font widthOfString: aString))/2.0)) 
			Y: (aPoint y - (0.4*self textScale*font height)) ;
			scaleBy: self textScale.
		canvas drawString: aString
	]
]

{ #category : #accessing }
VMElementRenderer >> showLabel [
	^ showLabel
]

{ #category : #accessing }
VMElementRenderer >> showLabel: anObject [
	showLabel := anObject
]

{ #category : #accessing }
VMElementRenderer >> textColor [
	^ textColor
]

{ #category : #accessing }
VMElementRenderer >> textColor: anObject [
	textColor := anObject
]

{ #category : #accessing }
VMElementRenderer >> textScale [
	^ textScale
]

{ #category : #accessing }
VMElementRenderer >> textScale: anObject [
	textScale := anObject
]
