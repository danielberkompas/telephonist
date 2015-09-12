##### Signed by https://keybase.io/dberkom
```
-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQIcBAABCgAGBQJV9FCdAAoJEKU82t1CbYQMf1oQAJCKV3gAjBwjrN6SCj0ERsr9
Tk31Am4SoidZ2jouLBk0vISHCaxYI9AmYrBxiPLsNtRwXF6C9HRqhTA+qCwxF7zZ
JF8VSi1Haj6uyRpzNQE4u2GsZM1e2x0zHYAyhb7V/qnuGLWldgR1uXWH7PNHdT4Z
ZqfqzqSyMxrybSEmTOYNKTV2IpCZCOYeIbaoXhzCi/MC81r3gbUuNit2HjngNPke
tJwX22cPs++xGNf58NBVgF10u8NFmTYuhw1U4gcKTfpYj0OdhSp7Dwfpl/W1xd4R
67HVkY70SaH2PYtQ51bRGVhIOCIKHjtCzw4ZgwR/yJNGdTbqKa5dqULMixMF8oOe
BEXV8CVXQ9caN37m+4ipM9mlZxxiJdqHEyL0IGgjXiu7dSU0UrV2HGHIeZAUO1vO
5lnWDDWoAZiuChohXykrdt4g+uPxBTIri/SEMHklO+G8voFr4RK4q76vqw0mzg4k
EMkBYFcYXXt2UJEUi9zfUcWlw/q6iGKIdW5oRIRFBpcWqT2AeSWRvLUlmPA/v1D8
sWL4Z2zRCOIiT4D9Jz3Ip97DrLeclT0g8KUJ2NC1Q1svMhDUxwjKLq+NzNEMDAwl
kNs8/lZ5FvYAyiKpbE2ifd0Dc300CO0InouFOnmDeDT88wfdp8r4sYzkvDtKbtYi
L+10Xl+p3t530rJOGFqK
=vYyt
-----END PGP SIGNATURE-----

```

<!-- END SIGNATURES -->

### Begin signed statement 

#### Expect

```
size  exec  file                     contents                                                        
            ./                                                                                       
1126          CHANGELOG.md           10ec54c93f353e554f3410554a197c82a85afae97dd61e54e4327676b89f03fb
1083          LICENSE                a24b375a609f6c84e82c1458fbb0383678e3f492ffb83912731fa5313831a7c9
7762          README.md              962cc55bd66075ea2b026c54195c795cf52c361b8ecae7cbac2373dcbe162a21
              lib/                                                                                   
                telephonist/                                                                         
3542              call_processor.ex  e3a2897b55e7cd32657ded106dbe721a68fcfd85a4c36f1d03dbe802569ff9a9
4911              event.ex           f15acb601fe78f9d12d9b566ff493f42618742e2b664d439007debdb0e91bb34
611               format.ex          38ebee8f9329d9e60ab8fe76dcb4aaf9b936be138d3c6db81df0acf5f7e7baf7
2085              logger.ex          3bdc0b588ca8cae752b3478cdfe4515dd4d78fc759119e87ab2abb5e070e3a4a
2933              ongoing_call.ex    02ae8d71d6b13cc9f4b3a6f3ff61e2ea5692bf98c0847e1097db7b4eea1769df
1356              state.ex           c211c10398c3e4d88590989d9297931919ba27e71942fb2e35f428240b829fc7
7974              state_machine.ex   35c7d9841269a5b144e763c11d608116b61191025de6eb88530b88b15215ea91
4633            telephonist.ex       217057a6bcb706b89d36096ba303ab58a24ff94774b8ff0267f3f457efc531c4
894           mix.exs                e8cd1dc04b55b6816b1d967717bda3b571f39af8b37c74e08a8574501d3c7c7c
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