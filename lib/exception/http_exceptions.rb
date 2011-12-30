class BadRequestError < ArgumentError
end

class NotFoundError < ArgumentError
end

class ForbiddenError < RuntimeError
end