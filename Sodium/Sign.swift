//
//  Sign.swift
//  Sodium
//
//  Created by Frank Denis on 12/28/14.
//  Copyright (c) 2014 Frank Denis. All rights reserved.
//

import Foundation

public class Sign {
    public let SeedBytes = Int(crypto_sign_seedbytes())
    public let PublicKeyBytes = Int(crypto_sign_publickeybytes())
    public let SecretKeyBytes = Int(crypto_sign_secretkeybytes())
    public let Bytes = Int(crypto_sign_bytes())
    public let Primitive = String.fromCString(crypto_sign_primitive())
    
    public typealias PublicKey = NSData
    public typealias SecretKey = NSData
    
    public struct KeyPair {
        public let publicKey: PublicKey
        public let secretKey: SecretKey
    }
    
    public func keyPair() -> KeyPair? {
        let pk = NSMutableData(length: PublicKeyBytes)
        if pk == nil {
            return nil
        }
        let sk = NSMutableData(length: SecretKeyBytes)
        if sk == nil {
            return nil
        }
        if crypto_sign_keypair(pk!.mutableBytesPtr, sk!.mutableBytesPtr) != 0 {
            return nil
        }
        return KeyPair(publicKey: PublicKey(data: pk!), secretKey: SecretKey(data: sk!))
    }
    
    public func keyPair(#seed: NSData) -> KeyPair? {
        if seed.length != SeedBytes {
            return nil
        }
        let pk = NSMutableData(length: PublicKeyBytes)
        if pk == nil {
            return nil
        }
        let sk = NSMutableData(length: SecretKeyBytes)
        if sk == nil {
            return nil
        }
        if crypto_sign_seed_keypair(pk!.mutableBytesPtr, sk!.mutableBytesPtr, seed.bytesPtr) != 0 {
            return nil
        }
        return KeyPair(publicKey: PublicKey(data: pk!), secretKey: SecretKey(data: sk!))
    }
    
    public func sign(message: NSData, secretKey: SecretKey) -> NSData? {
        if secretKey.length != SecretKeyBytes {
            return nil
        }
        let signedMessage = NSMutableData(length: message.length + Bytes)
        if signedMessage == nil {
            return nil
        }
        if crypto_sign(signedMessage!.mutableBytesPtr, nil, message.bytesPtr, CUnsignedLongLong(message.length), secretKey.bytesPtr) != 0 {
            return nil
        }
        return signedMessage
    }

    public func signature(message: NSData, secretKey: SecretKey) -> NSData? {
        if secretKey.length != SecretKeyBytes {
            return nil
        }
        let signature = NSMutableData(length: Bytes)
        if signature == nil {
            return nil
        }
        if crypto_sign_detached(signature!.mutableBytesPtr, nil, message.bytesPtr, CUnsignedLongLong(message.length), secretKey.bytesPtr) != 0 {
            return nil
        }
        return signature
    }
    
    public func verify(signedMessage: NSData, publicKey: PublicKey) -> Bool {
        let signature = signedMessage.subdataWithRange(NSRange(0..<Bytes))
        let message = signedMessage.subdataWithRange(NSRange(Bytes..<signedMessage.length))
        return verify(message, publicKey: publicKey, signature: signature)
    }
    
    public func verify(message: NSData, publicKey: PublicKey, signature: NSData) -> Bool {
        if publicKey.length != PublicKeyBytes {
            return false
        }
        return crypto_sign_verify_detached(signature.bytesPtr, message.bytesPtr, CUnsignedLongLong(message.length), publicKey.bytesPtr) == 0
    }
    
    public func open(signedMessage: NSData, publicKey: PublicKey) -> NSData? {
        if publicKey.length != PublicKeyBytes || signedMessage.length < Bytes {
            return nil
        }
        let message = NSMutableData(length: signedMessage.length - Bytes)
        if message == nil {
            return nil
        }
        var mlen: CUnsignedLongLong = 0;
        if crypto_sign_open(message!.mutableBytesPtr, &mlen, signedMessage.bytesPtr, CUnsignedLongLong(signedMessage.length), publicKey.bytesPtr) != 0 {
            return nil
        }
        return message
    }
}
