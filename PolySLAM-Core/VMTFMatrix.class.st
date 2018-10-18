"
This class represents 3x3 matrices for 2d homogeneous transformations.


class-side methods:
	- angle: <Number (radians)> translation: <Point>
		creates a new instance with translation and rotation set according to the parameters
	- identity
		creates an identity transformation (i.e. no translation and no rotation)
	- r: <rotation matrix> t: <translation vector>
		creates a new instance with translation and rotation set according to the parameters.
		the rotation matrix must be a 2x2 DhbMatrix (or compatible), the transformation vector
		can be a DhbVector or a sequential collection (e.g. an array) of at least size 2.
	- zeros
		creates a matrix with all values set to 0. 

"
Class {
	#name : #VMTFMatrix,
	#superclass : #DhbMatrix,
	#category : #'PolySLAM-Core-LinAlgebra'
}

{ #category : #'as yet unclassified' }
VMTFMatrix class >> angle: aFloat translation: aPoint [
	
	^(self identity)
		angle: aFloat;
		at: 1 at: 3 put: (aPoint x);
		at: 2 at: 3 put: (aPoint y);
		yourself.

]

{ #category : #'as yet unclassified' }
VMTFMatrix class >> identity [
	^(self rows: {
		{1.0.  0.0.  0.0}.
		{0.0.  1.0.  0.0}.
		{0.0.  0.0.  1.0}
	})

]

{ #category : #'as yet unclassified' }
VMTFMatrix class >> new [
	^(super new)
		initialize: 3;
		yourself.
]

{ #category : #'as yet unclassified' }
VMTFMatrix class >> r: rotMatrix t: transVector [
	
	^(self identity)
		rotMatrix: rotMatrix;
		translate: transVector;
		yourself.

]

{ #category : #'as yet unclassified' }
VMTFMatrix class >> zeros [
	^(self rows: {
		{0.0.  0.0.  0.0}.
		{0.0.  0.0.  0.0}.
		{0.0.  0.0.  0.0}
	})

]

{ #category : #accessing }
VMTFMatrix >> angle [

	^(self at: 2 at: 1) arcTan: (self at: 1 at: 1).
]

{ #category : #accessing }
VMTFMatrix >> angle: aNumber [
	"sets the rotation sub-matrix according to the provided value. the value is interpreted as radians"
	| sin cos |
	sin := aNumber sin.
	cos := aNumber cos.
	
	self at: 1 at: 1 put: cos.
	self at: 1 at: 2 put: (sin negated).
	self at: 2 at: 2 put: cos.
	self at: 2 at: 1 put: sin.
	
]

{ #category : #operation }
VMTFMatrix >> applyToCollection: aCollection [
	"applies the transformation to all objects in the collection. no copies are created, the original objects are being modified."

	aCollection do: [ :aPoint |
		self applyToPoint: aPoint.
	].
	
	^aCollection.
]

{ #category : #operation }
VMTFMatrix >> applyToPoint: aPoint [
	"applies the matrix transformation directly to the point (no copy created).
	returns the original object with its modified coordinates."
	| x y |
	
	x := aPoint x.
	y := aPoint y.
	
	aPoint setX: (
		((self at: 1 at: 1) * x) + 
		((self at: 1 at: 2) * y) + 
		(self at: 1 at: 3)
	) setY: (
		((self at: 2 at: 1) * x) + 
		((self at: 2 at: 2) * y) + 
		(self at: 2 at: 3)
	).
	
	^aPoint.
]

{ #category : #converting }
VMTFMatrix >> asRenderableElement [
	^VMTFRenderer model: self
]

{ #category : #accessing }
VMTFMatrix >> asVMTFMatrix [
	^self.
]

{ #category : #operation }
VMTFMatrix >> inverse [
	"faster implementation that takes the structure of the transformation matrix into account"
	| r t |
	
	r := self rotMatrix transpose.
	t := r * (self translate negated).
	
	^self class r: r t: t.
	

]

{ #category : #accessing }
VMTFMatrix >> length [
	^(
		( (self at: 1 at: 3) squared ) +
		( (self at: 2 at: 3) squared )
	) sqrt.
]

{ #category : #printing }
VMTFMatrix >> printString [
	^self class name,
		' angle: ',
		self angle printString,
		' translation: ',
		self translate asPoint printString.
]

{ #category : #'double dispatching' }
VMTFMatrix >> productWithMatrixFinal: aMatrix [
	"Overwritting the original method, because we need a VMTFMatrix instance instead of a DhbMatrix instance as returned object"
	|t|
	t :=self privateTranspose.
	^ aMatrix class rows: ( aMatrix rowsCollect: [ :row | t rowsCollect: [ :col | row * col]])
]

{ #category : #accessing }
VMTFMatrix >> rotMatrix [
	| mat |
	mat := VMMatrix2d rows: {
		{ self at: 1 at: 1.  self at: 1 at: 2 }.
		{ self at: 2 at: 1.  self at: 2 at: 2 }.
	}.
	
	^mat.

]

{ #category : #accessing }
VMTFMatrix >> rotMatrix: matrix [
	
	self at: 1 at: 1 put: ( matrix at: 1 at: 1 ).
	self at: 2 at: 1 put: ( matrix at: 2 at: 1 ).
	self at: 1 at: 2 put: ( matrix at: 1 at: 2 ).
	self at: 2 at: 2 put: ( matrix at: 2 at: 2 ).
	

]

{ #category : #operation }
VMTFMatrix >> transformPoint: aPoint [
	"using 'aPoint transform' allows Point instances and VMPoints instances to return the correct class, instead of converting VMPoints to  Points"
	^ aPoint transform: self
"	| x y |
	
	x := aPoint x.
	y := aPoint y.
	
	^(
		((self at: 1 at: 1) * x) + 
		((self at: 1 at: 2) * y) + 
		(self at: 1 at: 3)
	) @ (
		((self at: 2 at: 1) * x) + 
		((self at: 2 at: 2) * y) + 
		(self at: 2 at: 3)
	).
"
]

{ #category : #accessing }
VMTFMatrix >> translate [
	^(DhbVector new: 2)
		at: 1 put: (self at: 1 at: 3);
		at: 2 put: (self at: 2 at: 3);
		yourself.
]

{ #category : #accessing }
VMTFMatrix >> translate: aVector [
	
	self at: 1 at: 3 put: (aVector at: 1).
	self at: 2 at: 3 put: (aVector at: 2).

]
