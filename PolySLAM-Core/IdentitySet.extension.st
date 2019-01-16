Extension { #name : #IdentitySet }

{ #category : #'*PolySLAM-Core' }
IdentitySet >> asVMGraph [
	^ VMGraph new
		addAll: self
		yourself
]
