### polvo:if ENV=node ###

code = 'NODE'

### polvo:elif ENV=browser ###

code = 'BROWSER'

### polvo:else ###

code = 'UNIVERSAL'

### polvo:fi ###