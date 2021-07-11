package com.musketeer.ipfspass.encrypt

import java.security.MessageDigest
import javax.crypto.BadPaddingException
import javax.crypto.Cipher
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec

val CBC_PKCS5_PADDING : String = "AES/CBC/PKCS7Padding"
val AES : String = "AES"

fun ByteArray.toHex() = this.joinToString(separator = "") { it.toInt().and(0xff).toString(16).padStart(2, '0') }
fun String.hexStringToByteArray() = ByteArray(this.length / 2) { this.substring(it * 2, it * 2 + 2).toInt(16).toByte() }

object Aes {
    fun sha256(data: String): List<Byte> {
        val md = MessageDigest.getInstance("SHA-256")
        md.update(data.toByteArray())
        return md.digest().toList()
    }

    fun encryptData(masterPassword: String, rawData: String): String {
        val key = sha256(masterPassword)
        val iv = sha256("ipfspass-f0znNj85f4pz-"+masterPassword).subList(0, 16)
        val cipher = Cipher.getInstance(CBC_PKCS5_PADDING)
        cipher.init(Cipher.ENCRYPT_MODE, SecretKeySpec(key.toByteArray(), AES), IvParameterSpec(iv.toByteArray()))
        val encrypted = cipher.doFinal(rawData.toByteArray())
        return encrypted.toHex()
    }

    fun decryptData(masterPassword: String, encryptedData: String): String {
        val key = sha256(masterPassword)
        val iv = sha256("ipfspass-f0znNj85f4pz-"+masterPassword).subList(0, 16)
        val cipher = Cipher.getInstance(CBC_PKCS5_PADDING)
        cipher.init(Cipher.DECRYPT_MODE, SecretKeySpec(key.toByteArray(), AES), IvParameterSpec(iv.toByteArray()))
        try {
            val decryptedData = cipher.doFinal(encryptedData.hexStringToByteArray())
            return String(decryptedData)
        } catch (e: Exception) {
            return ""
        }
    }
}
