class BadRequestError             < ArgumentError
end

class NotFoundError               < ArgumentError
end

class ForbiddenError              < RuntimeError
end


class BearerAuthError             < RuntimeError
end

# Error thrown in case an attempt to authorize a request with a bearer token
# fails due to an invalid request (e.g. due to missing or duplicate 
# parameters). See draft-ietf-oauth-v2-bearer-08 for more details.
class BearerAuthInvalidRequest    < BearerAuthError
end

# Error thrown in case an attempt to authorize a request with a bearer token
# fails due to an invalid token (e.g. malformed, expired). 
# See draft-ietf-oauth-v2-bearer-08 for more details.
class BearerAuthInvalidToken      < BearerAuthError
end

# Error thrown in case an attempt to authorize a request with a bearer token
# fails due to an authorization to a too narrow scope in.  
# See draft-ietf-oauth-v2-bearer-08 for more details.
class BearerAuthInsufficientScope < BearerAuthError
end