import { authenticate, isAdmin } from './auth.js';
import type { AuthRequest } from './auth.js';
import type { Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

jest.mock('jsonwebtoken');

describe('Auth Middleware', () => {
  let mockRequest: Partial<AuthRequest>;
  let mockResponse: Partial<Response>;
  let nextFunction: NextFunction = jest.fn();

  beforeEach(() => {
    mockRequest = {
      headers: {},
    };
    mockResponse = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
    };
  });

  describe('authenticate', () => {
    it('should return 401 if no token is provided', () => {
      authenticate(mockRequest as AuthRequest, mockResponse as Response, nextFunction);
      expect(mockResponse.status).toHaveBeenCalledWith(401);
    });

    it('should call next() if token is valid', () => {
      mockRequest.headers = { authorization: 'Bearer validtoken' };
      (jwt.verify as jest.Mock).mockReturnValue({ id: '1', role: 'ADMIN' });

      authenticate(mockRequest as AuthRequest, mockResponse as Response, nextFunction);
      expect(nextFunction).toHaveBeenCalled();
      expect(mockRequest.user).toBeDefined();
    });
  });

  describe('isAdmin', () => {
    it('should return 403 if user is not ADMIN', () => {
      mockRequest.user = { id: '1', email: 'test@test.com', role: 'MEMBER', organizationId: 'org1' };
      isAdmin(mockRequest as AuthRequest, mockResponse as Response, nextFunction);
      expect(mockResponse.status).toHaveBeenCalledWith(403);
    });

    it('should call next() if user is ADMIN', () => {
      mockRequest.user = { id: '1', email: 'test@test.com', role: 'ADMIN', organizationId: 'org1' };
      isAdmin(mockRequest as AuthRequest, mockResponse as Response, nextFunction);
      expect(nextFunction).toHaveBeenCalled();
    });
  });
});
