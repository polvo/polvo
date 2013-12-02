# polvo:if ENV=node
code = 'NODE'
# polvo:elif ENV = browser
code = 'BROWSER'
# polvo:else
code = 'UNIVERSAL'
# polvo:fi

# polvo:if ENV!=browser
code = 'NOT BROWSER'
# polvo:fi


# polvo:if ENV=node
code = 'NODE2'
# polvo:elif ENV = browser
code = 'BROWSER2'
# polvo:else
code = 'UNIVERSAL2'
# polvo:fi


# polvo:if ENV != browser
code = 'NOT BROWSER2'
# polvo:fi