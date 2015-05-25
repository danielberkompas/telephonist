##### Signed by https://keybase.io/dberkom
```
-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQIcBAABCgAGBQJVY6oDAAoJEKU82t1CbYQMsyQP/20O5ST7GsWNxSHp5nyMsQRk
izYfz+fYEoJKUhpVcy6XfLAbe7rUP6A3rVfxEFG7HZ/3wn2g5JxeC4+lzjGs6d8M
E05XYaC/hIWXX5DKj4wgTHyEH2R5wzf+tIXlYRthTA9vZkDQZU/SS/2MbKZ7w9Ib
MN5jf1KbfxG/QAsp+rStQLU2+2f4ifmYdTWtctaXPP3xsXVKu0YCVsfASBYO/sEg
Wl0wBR/AtNLNIymb/ih/BYvVZTK4v/pSd/+1PAMe5WUfKIgqlOIDzSCLJdxMI4K2
iGiPTOvqL6SiUXO4Y8ZSgGxhh0ywdox7GW5NOFg11PvdIHR13O/HjSy/+XwaJZGx
J5pLkga6iUjRwNyov+w394u8RAta2dFkR6i3D6GY0idUnKcD3j5nOl0+GSymTwgH
KGQyClKvxknWpoqVLbpIWgXQovFL1DZBygskNFsjzQPsRcnP5V1kqifXSc1GLgUA
q7sLsfQjTUMIM57MnzQb9uvexTW8Q1+BkQQtmQa+z/ldDfrVNpjEvtYZ6rV5I52A
Lx+0Pk6OfA50HBYvY+srPBBhANEiS+1m57omacdmlytAdcd0uJHevijCzHl95K78
jrtWiduBUmpODZYzfgt1wlWzrpQN4OBjlfS6+C6SmlVEu/24PTXNnZQMdDhMFq7Q
TsSlfZ9bg0ncvVOnA5ot
=Ce3O
-----END PGP SIGNATURE-----

```

<!-- END SIGNATURES -->

### Begin signed statement 

#### Expect

```
size  exec  file                           contents                                                        
            ./                                                                                             
39            .gitignore                   6852329ebe6cd9ed388b24316ea68612637cba18d8e6d508c502bafbac0a6c41
619           .travis.yml                  34067725317b027149862d11a95ffe3adc6b92e1b455c0c49fff8de54d74439b
153           CHANGELOG.md                 42e628018fccb4a446a68c506c2e9437df5eb0ab0071c89cf4248f2dc3a398d6
1083          LICENSE                      a24b375a609f6c84e82c1458fbb0383678e3f492ffb83912731fa5313831a7c9
322           NOTICE                       9b9f53c89cde0e23ea4f718683e5f76d576d8129dc4a5b3d2597128bc61024ad
7773          README.md                    e66eda7a6963f4d91662213ddb046ec96e3c56923488f7c63b784f8b04e8f766
              config/                                                                                      
1072            config.exs                 256a6f00b1a33727754504b2c5cf21a03c9223326225c87ce95d9fb6d462997b
              lib/                                                                                         
                telephonist/                                                                               
3799              call_processor.ex        dc7083c648941d85484aab50c0bab7b7d792e144f69957bba1999c962ed711cf
4911              event.ex                 f15acb601fe78f9d12d9b566ff493f42618742e2b664d439007debdb0e91bb34
2085              logger.ex                3bdc0b588ca8cae752b3478cdfe4515dd4d78fc759119e87ab2abb5e070e3a4a
1323              ongoing_call.ex          aa1a09704f5d37151587ef9bc3d5a01b5f53cfec7e6cc2757ae132dacb5f5359
1356              state.ex                 c211c10398c3e4d88590989d9297931919ba27e71942fb2e35f428240b829fc7
7974              state_machine.ex         35c7d9841269a5b144e763c11d608116b61191025de6eb88530b88b15215ea91
4647            telephonist.ex             7d094a7fa29585a2ef71e8d83ce51ce3b2d7d9e8faa0ef6e8ff24c301aec2076
926           mix.exs                      03036873463f098317d29baadcb9087775d035e0452fdfe47991c911157d295a
240           mix.lock                     e60c993dd920f8273726be63c5c7a4813ada67fecdd424be5d6b58191fc1e98f
              script/                                                                                      
621   x         release                    ac5c0088bca2a25568fa5bb438ea19666c01b053cdb4d116676ba85c20ab3bf5
              test/                                                                                        
                telephonist/                                                                               
2609              call_processor_test.exs  82ab45df5ae69466e8e4b54ae3ac8429b35904aadec23af45b1821c0dd047a1f
1650              ongoing_call_test.exs    b079be608d420e6196280a145b2ae845d0ea8013bc3c79ec75a853554c66899b
1860              state_machine_test.exs   2db4d3541a12e124776f2ad83b57b8393347815c2718c83724080880d8088db2
51              telephonist_test.exs       ad39cdf77c98bfb17328019643766c5434ab9e7ba133194413814c91a68b1669
15              test_helper.exs            b086ec47f0c6c7aaeb4cffca5ae5243dd05e0dc96ab761ced93325d5315f4b12
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