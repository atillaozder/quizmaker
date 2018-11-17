
from rest_framework.permissions import BasePermission, SAFE_METHODS
from account.models import (Instructor, Student)

class IsOwnerOrReadOnly(BasePermission):
    """
    Object-level permission to only allow owners of an object to edit it.
    Assumes the model instance has an `owner` attribute.
    """
    def has_object_permission(self, request, view, obj):
        # Read permissions are allowed to any request,
        # so we'll always allow GET, HEAD or OPTIONS requests.
        if request.method in SAFE_METHODS:
            return True
        # Instance must have an attribute named `owner`.
        try:
            return obj.owner.user == request.user
        except:
            return obj.owner == request.user
        return obj.owner == request.user

class IsAuthenticated(BasePermission):
    """
    Allows access only to authenticated users.
    """
    message = {"error_code": 4030}

    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated

class IsActive(BasePermission):
    """
    Allows access only to active users.
    """
    message = {
        "error": "not_active",
        "error_description": "Account is not active. You will get this message if a user is delete his/her account",
        "error_code": 4032
    }

    def has_permission(self, request, view):
        return request.user.is_active
