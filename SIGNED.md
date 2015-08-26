##### Signed by https://keybase.io/dberkom
```
-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQIcBAABCgAGBQJV3c0SAAoJEKU82t1CbYQMv3gQAIPnv76HPdrM1Mj4T6XJqA0c
4pz7XMG17ouAXP0wG02pCrI2sE3m6zwCetLrl2MHfW8wvUAZWfTCz9lGWkmraynM
R/0WOkCOFwCNuRZorVdiQWlw5nYQJpAUIattJ4I8WCDillBPOrS/k8Zt1OL4dMT6
c7cZ4rrtuAO0J6jrZQGEl4MZLuuC9cESBAFSkfvlYPZtuDf004TAz6JkoUTH/8Lx
ELOWxxzV6V2i8Z4UNZ56wObg3d7pi8gnG0TS8LvZRpls4X/N3u/8krunhdyvh/xG
fVSjQZe48tPkbIp2s4Ny5Fp7XcaXfMj3Q/c94Q3g+NqSwS5HzBOGOePcgnlz2k1q
W8qjOkz7EPZIXFIuVoMCreXtzlKqvqFLQbLF3xm6NQ9ERpbG8Df9xFuzMenMTRc2
b1nfA9o1YXTnr8AU+mY9Q4I11vAA1mLLIlMLKFr7ZK7d+a/Ha+3RfKgKQ+F/Mwjy
tkQNhkvgTF+nAcBrA47/t34AkjyrEAIzeSkOFBlwlscuCOhP2y66AoYeKaAYd47E
6qhGpeT5n5pXU76CI+qRtky62JnfA5BVyUwKezJEjcWUlYv7DQYo+T1ByteOKEbj
IyyerzCSwwJxAoV5UBgmmrdqTysiH1cw1Moe3KjYEMstR+50ZcxV1PLU+Kz0vJ1r
ypXhAz4z5jkPHUgM+/nM
=/m0E
-----END PGP SIGNATURE-----

```

<!-- END SIGNATURES -->

### Begin signed statement 

#### Expect

```
size  exec  file                     contents                                                        
            ./                                                                                       
771           CHANGELOG.md           4f6b94f2539750a9cf08df42770a14a95a5ef4195d60956ab29cc53e5b03efa8
1083          LICENSE                a24b375a609f6c84e82c1458fbb0383678e3f492ffb83912731fa5313831a7c9
7874          README.md              abcac53f8d00374f284c21f035d60ae549051384e4737bb6091041120cd5f6a3
              lib/                                                                                   
                telephonist/                                                                         
3640              call_processor.ex  d58a4d435aeb7365de6f5fb8bbb6482274125f797accf05f4deea0ed7ba316fa
4911              event.ex           f15acb601fe78f9d12d9b566ff493f42618742e2b664d439007debdb0e91bb34
611               format.ex          38ebee8f9329d9e60ab8fe76dcb4aaf9b936be138d3c6db81df0acf5f7e7baf7
2085              logger.ex          3bdc0b588ca8cae752b3478cdfe4515dd4d78fc759119e87ab2abb5e070e3a4a
2933              ongoing_call.ex    02ae8d71d6b13cc9f4b3a6f3ff61e2ea5692bf98c0847e1097db7b4eea1769df
1356              state.ex           c211c10398c3e4d88590989d9297931919ba27e71942fb2e35f428240b829fc7
7974              state_machine.ex   35c7d9841269a5b144e763c11d608116b61191025de6eb88530b88b15215ea91
4633            telephonist.ex       217057a6bcb706b89d36096ba303ab58a24ff94774b8ff0267f3f457efc531c4
896           mix.exs                9e25efadca0591f6aa103e2b5d76cceb48851a70899e3990a767875189a7335e
```

#### Ignore

```
/SIGNED.md
```

#### Presets

```
git      # ignore .git and anything as described by .gitignore files
dropbox  # ignore .dropbox-cache and other Dropbox-related files    
kb       # ignore anything as described by .kbignore files          
```

<!-- summarize version = 0.0.9 -->

### End signed statement

<hr>

#### Notes

With keybase you can sign any directory's contents, whether it's a git repo,
source code distribution, or a personal documents folder. It aims to replace the drudgery of:

  1. comparing a zipped file to a detached statement
  2. downloading a public key
  3. confirming it is in fact the author's by reviewing public statements they've made, using it

All in one simple command:

```bash
keybase dir verify
```

There are lots of options, including assertions for automating your checks.

For more info, check out https://keybase.io/docs/command_line/code_signing