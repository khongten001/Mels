/**************************************************************************************************
 * ==> QR_Cache ----------------------------------------------------------------------------------*
 **************************************************************************************************
 * Description : Generic data caching class                                                       *
 * Developer   : Jean-Milost Reymond                                                              *
 * Copyright   : 2015 - 2016, this file is part of the Mels library, all right reserved           *
 **************************************************************************************************/

#ifndef QR_CacheH
#define QR_CacheH

// std
#include <map>

/**
* Generic data caching class
*@author Jean-Milost Reymond
*/
template <class T, class U>
class QR_Cache
{
    public:
        typedef std::map<T, U> ICacheDictionary;

        /**
        * Called when new value is added to cache
        *@param key - newly added key
        *@param value - newly added avlue
        */
        #ifdef __CODEGEARC__
            typedef void __fastcall (__closure *ITfOnAdd)(const T& key, const U& value);
        #else
            typedef void (*ITfOnAdd)(const T& key, const U& value);
        #endif

        /**
        * Called when value is deleted from cache
        *@param key - deleting key
        *@param[in, out] value - deleting value
        *@return true if value can be deleted from cache, otherwise false
        */
        #ifdef __CODEGEARC__
            typedef bool __fastcall (__closure *ITfOnDelete)(const T& key, U& value);
        #else
            typedef bool (*ITfOnDelete)(const T& key, U& value);
        #endif

        QR_Cache();
        virtual ~QR_Cache();

        /**
        * Adds value to cache
        *@param key - key
        *@param value - value to add
        *@return true on success, otherwise false
        */
        virtual bool Add(const T& key, const U& value);

        /**
        * Deletes value from cache
        *@param key - key
        */
        virtual void Delete(T key);

        /**
        * Gets value from cache
        *@param key - key
        *@param[out] value - value to get
        *@return true if value exists, otherwise false
        */
        virtual bool Get(const T& key, U& value) const;

        /**
        * Sets OnAdd callback
        *@param fHandle - function handle
        */
        virtual void Set_OnAdd(ITfOnAdd fHandle);

        /**
        * Sets OnDelete callback
        *@param fHandle - function handle
        */
        virtual void Set_OnDelete(ITfOnDelete fHandle);

    protected:
        ICacheDictionary m_Cache;
        bool             m_DoOwnValue;
        ITfOnAdd         m_fOnAdd;
        ITfOnDelete      m_fOnDelete;
};

//--------------------------------------------------------------------------------------------------
// QR_Cache
//--------------------------------------------------------------------------------------------------
template <class T, class U>
QR_Cache<T, U>::QR_Cache() :
    m_fOnAdd(NULL),
    m_fOnDelete(NULL)
{}
//--------------------------------------------------------------------------------------------------
template <class T, class U>
QR_Cache<T, U>::~QR_Cache()
{
    // iterate through cache items to delete
    for (ICacheDictionary::iterator it = m_Cache.begin(); it != m_Cache.end(); ++it)
        // notify that item will be deleted
        if (m_fOnDelete)
            m_fOnDelete(it->first, it->second);

    m_Cache.clear();
}
//--------------------------------------------------------------------------------------------------
template <class T, class U>
bool QR_Cache<T, U>::Add(const T& key, const U& value)
{
    // search for existing item in cache
    ICacheDictionary::iterator it = m_Cache.find(key);

    // found it?
    if (it != m_Cache.end())
    {
        // notify that previous item is about to be deleted
        if (m_fOnDelete && !m_fOnDelete(it->first, it->second))
            return false;

        // delete previous item from cache
        m_Cache.erase(it);
    }

    // notify that item is about to be added
    if (m_fOnAdd)
        m_fOnAdd(key, value);

    // add item to cache
    m_Cache[key] = value;
    return true;
}
//--------------------------------------------------------------------------------------------------
template <class T, class U>
void QR_Cache<T, U>::Delete(T key)
{
    // search for existing item in cache
    ICacheDictionary::iterator it = m_Cache.find(key);

    // found it?
    if (it == m_Cache.end())
        return;

    // notify that item is about to be deleted
    if (m_fOnDelete && !m_fOnDelete(it->first, it->second))
        return;

    // delete item from cache
    m_Cache.erase(it);
}
//--------------------------------------------------------------------------------------------------
template <class T, class U>
bool QR_Cache<T, U>::Get(const T& key, U& value) const
{
    // search for existing item in cache
    ICacheDictionary::const_iterator it = m_Cache.find(key);

    // found it?
    if (it == m_Cache.end())
        return false;

    // get item from cache
    value = it->second;
    return true;
}
//--------------------------------------------------------------------------------------------------
template <class T, class U>
void QR_Cache<T, U>::Set_OnAdd(ITfOnAdd fHandle)
{
    m_fOnAdd = fHandle;
}
//--------------------------------------------------------------------------------------------------
template <class T, class U>
void QR_Cache<T, U>::Set_OnDelete(ITfOnDelete fHandle)
{
    m_fOnDelete = fHandle;
}
//--------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------
// RAD studio
//--------------------------------------------------------------------------------------------------
#ifdef __CODEGEARC__
    // needed to avoid the W8058 error "Cannot create pre-compiled header: header incomplete" warning in BCC compilers
    ;
#endif
//--------------------------------------------------------------------------------------------------

#endif