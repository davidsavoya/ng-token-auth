suite 'password update', ->
  dfd = null
  suite 'successful password update', ->
    successResp =
      success: true

    setup ->
      $httpBackend
        .expectPUT('/api/auth/password')
        .respond(201, {success: true})

      dfd = $auth.updatePassword({
        password: 'secret123'
        password_confirmation: 'secret123'
      })

      $httpBackend.flush()

    test 'success event should return user info', ->
      assert $rootScope.$broadcast.calledWithMatch('auth:password-change-success', successResp)

    test 'promise is resolved', ->
      dfd.then(-> assert(true))
      $timeout.flush()


  suite 'directive access', ->
    args =
      password: 'secret123'
      password_confirmation: 'secret123'

    setup ->
      $httpBackend
        .expectPUT('/api/auth/password')
        .respond(201, {success: true})

      sinon.spy($auth, 'updatePassword')

      $rootScope.updatePassword(args)
      $httpBackend.flush()

    test '$auth.updatePassword was called from $rootScope', ->
      assert $auth.updatePassword.calledWithMatch(args)

  suite 'failed password update', ->
    errorResp =
      success: false
      error: ['sry']

    setup ->
      $httpBackend
        .expectPUT('/api/auth/password')
        .respond(401, errorResp)

      dfd = $auth.updatePassword({
        password: 'secret123'
        password_confirmation: 'secret123'
      })

      $httpBackend.flush()

    test 'new user is NOT defined in the root scope', ->
      assert.equal(undefined, $rootScope.user.uid)

    test 'error should be broadcast by rootscope', ->
      assert $rootScope.$broadcast.calledWithMatch('auth:password-change-error', errorResp)

    test 'promise is rejected', ->
      dfd.catch(-> assert(true))
      $timeout.flush()

